/** @format */

import * as udviz from 'ud-viz';

//itowns
import * as itowns from 'itowns';
export { itowns };
//itowns
import * as debug from 'debug';
export { debug };
import { Utils } from './Utils';

const app = new udviz.Templates.AllWidget();
const myUtils = new Utils();
var streaming = Boolean(true);
var sources;
var dynamicLayer;


console.log("Folder in .env is ",FOLDER);

//app.start('../assets/config/config.json').then((config) => {
app.start('../assets/config/config.json').then((config) => {  


  ////// LAYER CHOICE MODULE
  const layerChoice = new udviz.Widgets.LayerChoice(app.view3D.getLayerManager());
  app.addModuleView('layerChoice', layerChoice);

  //CAMERA SETTINGS
  let pos_x = parseInt(app.config['camera']['coordinates']['position']['x']);
  let pos_y = parseInt(app.config['camera']['coordinates']['position']['y']);
  let pos_z = parseInt(app.config['camera']['coordinates']['position']['z']);
  let quat_x = parseFloat(app.config['camera']['coordinates']['quaternion']['x']);
  let quat_y = parseFloat(app.config['camera']['coordinates']['quaternion']['y']);
  let quat_z = parseFloat(app.config['camera']['coordinates']['quaternion']['z']);
  let quat_w = parseFloat(app.config['camera']['coordinates']['quaternion']['w']);
  app.view3D.getCamera().position.set(pos_x, pos_y, pos_z);
  app.view3D.getCamera().quaternion.set(quat_x, quat_y, quat_z, quat_w);
  //app.view3D.getCamera().updateProjectionMatrix();
  
  if(!streaming){
    sources = getSourceListfromGeojsonCollection(app.config["dynamic_layer"]);
    console.log("Nb initial sources " + sources.length);
    myUtils.foo(app.view3D.getItownsView());
    setTimeout(() => { 
      runTimelapse(app.view3D.getItownsView(),dynamicLayer,sources,1000);
    }, 200);
  }
});

if(streaming){
  let wSocket = new WebSocket('ws://localhost:6868/');

  WebSocket.prototype.sendMessage = function (message) {
    this.send(message);
    console.log('Message sent: ' + message);
  }

  const modelPath = FOLDER + '/ReAgent/models/Gratte_Ciel_Demo.gaml';
  const experimentName = 'Demo';

  const species1Name = 'people';
  const attribute1Name = 'type';
  const species2Name = 'building';
  const attribute2Name = 'type';
  const species3Name = 'road';
  const attribute3Name = 'type';

  let geojson;
  let gama_layer;

  let socket_id = 0;
  let exp_id = 0;

  let layer0added = 0;
  let layer1added = 0;
  let layer2added = 0;


  let queue = [];
  let request = "";
  let result = "";
  let updateSource;
  let executor_speed = 1;
  let executor = setInterval(() => {
    if (queue.length > 0 && request === "") {
      request = queue.shift();
      request.exp_id = exp_id;
      request.socket_id = socket_id;
      wSocket.send(JSON.stringify(request));
      wSocket.onmessage = function (event) {
        console.log("message recieved");
        let msg = event.data;
        if (event.data instanceof Blob) { } else {
          if (request.callback) {
            request.callback(msg);
          } else {
            request = "";
          }
        }
      }
    }

  }, executor_speed);
  
  wSocket.onclose = function (event) {
    clearInterval(executor);
    clearInterval(updateSource);
  };

  wSocket.onopen = function (event) {

    let cmd = {
      "type": "launch",
      "model": modelPath,
      "experiment": experimentName,
      "callback": function (e) {
        result = JSON.parse(e);
        if (result.exp_id) exp_id = result.exp_id;
        if (result.socket_id) socket_id = result.socket_id;
        request = "";
      }
    };
    queue.push(cmd);
    cmd = {
      "type": "play",
      "socket_id": socket_id,
      "exp_id": exp_id
    };
    queue.push(cmd);

    // STATIC LAYER
    //Building
    cmd = {
      'type': 'output',
      'species': species2Name,
      'attributes': [attribute2Name],
      "crs": 'EPSG:3946',
      'socket_id': socket_id,
      'exp_id': exp_id,
      "callback": function (message) {
        console.log("adding building");
        if (typeof event.data == "object") {
        } else {
          geojson = null;
          geojson = JSON.parse(message);
          if (layer1added) {
            app.view3D.getItownsView().removeLayer("BUILDING");
          }
          layer1added = 1;

          _source = new itowns.FileSource({
            fetchedData: geojson,
            crs: 'EPSG:3946',
            format: 'application/json',
          });

          gama_layer = new itowns.FeatureGeometryLayer('BUILDING', {
            // Use a FileSource to load a single file once
            source: _source,
            transparent: true,
            opacity: 1,
            style: new itowns.Style({
              fill: {
                extrusion_height: 10,
                color: myUtils.setBuildingColor,
              }
            })
          });

          app.view3D.getItownsView().addLayer(gama_layer);

          app.update3DView();
        }
        request = "";//IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
      }
    };
    queue.push(cmd);
    //road
    /*cmd = {
      'type': 'output',
      'species': species3Name,
      'attributes': [attribute3Name],
      "crs": 'EPSG:3946',
      'socket_id': socket_id,
      'exp_id': exp_id,
      "callback": function (message) {
        if (typeof event.data == "object") {
        } else {
          geojson = null;
          geojson = JSON.parse(message);
          if (layer2added) {
            app.view3D.getItownsView().removeLayer("ROAD");
          }
          layer2added = 1;

          _source = new itowns.FileSource({
            fetchedData: geojson,
            crs: 'EPSG:3946',
            format: 'application/json',
          });

          gama_layer = new itowns.FeatureGeometryLayer('ROAD', {
            source: _source,
            transparent: true,
            opacity: 1,
            style: new itowns.Style({
              stroke: {
                color: myUtils.setRoadColor,
              }
            })
          });

          app.view3D.getItownsView().addLayer(gama_layer);

          app.update3DView();
        }
        request = "";//IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
      }
    };*/
    // queue.push(cmd);
    
    //DYNAMIC LAYER (PEOPLE)
    let countIDLayer = 0;
    updateSource = setInterval(() => {
      cmd = {
        'type': 'output',
        'species': species1Name,
        'attributes': [attribute1Name],
        "crs": 'EPSG:3946',
        'socket_id': socket_id,
        'exp_id': exp_id,
        "callback": function (message) {
          console.log("adding people");
          if (typeof event.data == "object") {
          } else {
            geojson = null;
            geojson = JSON.parse(message);
            if (layer0added) {
              //gama_layer.delete();
              app.view3D.getItownsView().removeLayer(countIDLayer);
            }
            layer0added = 1;

            _source = new itowns.FileSource({
              fetchedData: geojson,
              crs: 'EPSG:3946',
              format: 'application/json',
            });
            countIDLayer++
            gama_layer = new itowns.FeatureGeometryLayer(countIDLayer, {
              // Use a FileSource to load a single file once
              source: _source,
              transparent: true,
              opacity: 1,
              style: new itowns.Style({
                fill: {
                  //base_altitude: setAltitude,
                  extrusion_height: 10,
                  color: myUtils.setPeopleColor,
                }
              })
            });
            app.view3D.getItownsView().addLayer(gama_layer);
            app.update3DView();
          }
          request = "";//IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
        }
      };
      queue.push(cmd);
      
      
    }, 200);
  }
  var _source;
  wSocket.onerror = function (event) {
    console.log('An error occurred. Sorry for that.');
  }
}


/*
  Read all GeoJson stored in the directory (geojsonCollectionUrl)
  They are stored as itowns.FileSource 
*/
function getSourceListfromGeojsonCollection(parameters){
  let sourceList = new Array();
  for(let i = 0; i < parameters["step"];i++){
    var _source = new itowns.FileSource({
      url: parameters["geojsonCollectionUrl"] + i +".geojson",
      crs: parameters["crs"],
      format: parameters["format"]
    });
    sourceList.push(_source);
  }
  return sourceList;
}

/**
   * Run a simulation using a geojsonCollection. 
   * @param itownsView 
   * @param layer The FeatureGeometryLayer that will be updated (filled with step 0)
   * @param stepTime Time between each step of the timelapse
   */
 function runTimelapse(itownsView,layer,_sources,stepTime){
  let step = 0;
  let interval = setInterval( () => {
    if(step > _sources.length-1){
     clearInterval(interval);
     console.log("Simulation Done with " + step + " Steps");
    }
    else{
      if (step>0){
        itownsView.removeLayer("current_layer"+(step-1));
      }
      layer = new itowns.FeatureGeometryLayer("current_layer"+step, {
        source: _sources[step],
        transparent: true,
        batchId: function (property) { 
          return parseInt(property.geojson.id); },  
        opacity: 1,
        style: new itowns.Style({
          fill: {
            extrusion_height: 1,
            color: myUtils.setPeopleColor,
          },
        }),
      });
      itownsView.addLayer(layer);
      app.update3DView();
    }
    step += 1;
  },stepTime);
}



function onReceiveMsg(e) {
  console.log(e);
  request = "";
}

