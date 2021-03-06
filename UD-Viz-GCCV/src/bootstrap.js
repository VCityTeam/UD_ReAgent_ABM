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

//app.start('../assets/config/config.json').then((config) => {
app.start('../assets/config/config_world_map.json').then((config) => {  
  //app.addBaseMapLayer();

  // app.addElevationLayer();

  //app.setupAndAdd3DTilesLayers();

  ////// LAYER CHOICE MODULE
  const layerChoice = new udviz.Widgets.LayerChoice(app.layerManager);
  app.addModuleView('layerChoice', layerChoice);

  //CAMERA SETTINGS
  let pos_x = parseInt(app.config['camera']['coordinates']['position']['x']);
  let pos_y = parseInt(app.config['camera']['coordinates']['position']['y']);
  let pos_z = parseInt(app.config['camera']['coordinates']['position']['z']);
  let quat_x = parseFloat(app.config['camera']['coordinates']['quaternion']['x']);
  let quat_y = parseFloat(app.config['camera']['coordinates']['quaternion']['y']);
  let quat_z = parseFloat(app.config['camera']['coordinates']['quaternion']['z']);
  let quat_w = parseFloat(app.config['camera']['coordinates']['quaternion']['w']);
  app.view.camera.camera3D.position.set(pos_x, pos_y, pos_z);
  app.view.camera.camera3D.quaternion.set(quat_x, quat_y, quat_z, quat_w);
});

let wSocket = new WebSocket('ws://localhost:6868/');

WebSocket.prototype.sendMessage = function (message) {
  this.send(message);
  console.log('Message sent: ' + message);
}

const modelPath = '/Users/arno/Projects/GitHub/UD_ReAgent_ABM/ReAgent/models/Gratte_Ciel_Basic.gaml';
const experimentName = 'GratteCielErasme';

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
      if (typeof event.data == "object") {
      } else {
        geojson = null;
        geojson = JSON.parse(message);
        if (layer1added) {
          app.view.removeLayer("BUILDING");
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

        app.view.addLayer(gama_layer);

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
          app.view.removeLayer("ROAD");
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

        app.view.addLayer(gama_layer);

        app.update3DView();
      }
      request = "";//IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
    }
  };*/
  queue.push(cmd);
  
  //DYNAMIC LAYER (PEOPLE)
  updateSource = setInterval(() => {
    cmd = {
      'type': 'output',
      'species': species1Name,
      'attributes': [attribute1Name],
      "crs": 'EPSG:3946',
      'socket_id': socket_id,
      'exp_id': exp_id,
      "callback": function (message) {
        if (typeof event.data == "object") {
        } else {
          geojson = null;
          geojson = JSON.parse(message);
          if (layer0added) {
            //gama_layer.delete();
            app.view.removeLayer("PEOPLE");
          }
          layer0added = 1;

          _source = new itowns.FileSource({
            fetchedData: geojson,
            crs: 'EPSG:3946',
            format: 'application/json',
          });
          gama_layer = new itowns.FeatureGeometryLayer("PEOPLE", {
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
          app.view.addLayer(gama_layer);
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


function onReceiveMsg(e) {
  console.log(e);
  request = "";
}

