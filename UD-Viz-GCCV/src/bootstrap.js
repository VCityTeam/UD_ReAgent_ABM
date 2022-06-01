/** @format */

import * as udviz from 'ud-viz';

//itowns
import * as itowns from 'itowns';
export { itowns };
//itowns
import * as debug from 'debug';
export { debug };


const app = new udviz.Templates.AllWidget();

app.start('../assets/config/config.json').then((config) => {
  //app.addBaseMapLayer();

 // app.addElevationLayer();

  //app.setupAndAdd3DTilesLayers();

  ////// REQUEST SERVICE
  const requestService = new udviz.Components.RequestService();

  ////// ABOUT MODULE
  const about = new udviz.Widgets.AboutWindow();
  app.addModuleView('about', about);

  ////// AUTHENTICATION MODULE
  const authenticationService =
    new udviz.Widgets.Extensions.AuthenticationService(
      requestService,
      app.config
    );

  const authenticationView = new udviz.Widgets.Extensions.AuthenticationView(
    authenticationService
  );
  app.addModuleView('authentication', authenticationView, {
    type: udviz.Templates.AllWidget.AUTHENTICATION_MODULE,
  });

 
  ////// CAMERA POSITIONER
  const cameraPosition = new udviz.Widgets.CameraPositionerView(
    app.view,
    app.controls
  );
  app.addModuleView('cameraPositioner', cameraPosition);

  ////// LAYER CHOICE MODULE
  const layerChoice = new udviz.Widgets.LayerChoice(app.layerManager);
  app.addModuleView('layerChoice', layerChoice);

  const inputManager = new udviz.Components.InputManager();
  ///// SLIDESHOW MODULE
  const slideShow = new udviz.Widgets.SlideShow(app, inputManager);
  app.addModuleView('slideShow', slideShow);


  let pos_x = parseInt(app.config['camera']['coordinates']['position']['x']);
  let pos_y = parseInt(app.config['camera']['coordinates']['position']['y']);
  let pos_z = parseInt(app.config['camera']['coordinates']['position']['z']);
  let quat_x = parseFloat(app.config['camera']['coordinates']['quaternion']['x']);
  let quat_y = parseFloat(app.config['camera']['coordinates']['quaternion']['y']);
  let quat_z = parseFloat(app.config['camera']['coordinates']['quaternion']['z']);
  let quat_w = parseFloat(app.config['camera']['coordinates']['quaternion']['w']);

  console.log(app.view.camera.camera3D);
  app.view.camera.camera3D.position.set(pos_x, pos_y, pos_z);
  app.view.camera.camera3D.quaternion.set(quat_x, quat_y, quat_z, quat_w);

});

let wSocket = new WebSocket('ws://localhost:6868/');


WebSocket.prototype.sendMessage = function (message) {
  this.send(message);
  console.log('Message sent: ' + message);
}

function log(e) {
  console.log(e);
}

function setAltitude(properties) {
  console.log("properties");
  console.log(properties);
}

function setPeopleColor(properties) {
  if (properties.type === "car"){
    return 'red';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "bike"){
    return 'green';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "pedestrian"){
    return 'blue';//new itowns.THREE.Color(0xaaaaaa);
  }
}

function setBuildingColor(properties) {
  if (properties.type === "apartments"){
    return 'blue';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "school"){
    return 'green';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "construction"){
    return 'yellow';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "civic"){
    return 'orange';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "church"){
    return 'white';//new itowns.THREE.Color(0xaaaaaa);
  }
  if (properties.type === "service"){
    return 'pink';//new itowns.THREE.Color(0xaaaaaa);
  }
  return 'blue';
}


const modelPath = '/Users/arno/Projects/GitHub/UD_ReAgent_ABM/ReAgent/models/Gratte_Ciel_Basic.gaml';
const experimentName = 'GratteCielErasme';
const species1Name = 'people';
const attribute1Name = 'type';
const species2Name = 'building';
const attribute2Name = 'type';

let geojson;
let gama_layer;

let socket_id = 0;
let exp_id = 0;

let layer0added = 0;
let layer1added = 0;


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
    //log("request " + JSON.stringify(request));
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
      log(e);
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


  updateSource = setInterval(() => {
    cmd = {
      'type': 'output',
      'species': species1Name,
      'attributes': [attribute1Name],
      "crs":'EPSG:3946',
      'socket_id': socket_id,
      'exp_id': exp_id,
      "callback": function (message) {
        if (typeof event.data == "object") {
        } else {
        geojson = null;
        geojson = JSON.parse(message);
        if (layer0added) {
          //debugger;
          //app.view.getLayerById("GAMA").delete();
          app.view.removeLayer("GAMA");
          
        }  
        layer0added = 1;

        _source = new itowns.FileSource({
          fetchedData: geojson,
          crs: 'EPSG:3946',
          format: 'application/json',
        });

        gama_layer = new itowns.FeatureGeometryLayer("GAMA", {
          // Use a FileSource to load a single file once
          source: _source,
          transparent: true,
          opacity: 1,
          style: new itowns.Style({
            fill: {
                  //base_altitude: setAltitude,
                  extrusion_height: 1,
                  color: setPeopleColor ,
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
    cmd = {
      'type': 'output',
      'species': species2Name,
      'attributes': [attribute2Name],
      "crs":'EPSG:3946',
      'socket_id': socket_id,
      'exp_id': exp_id,
      "callback": function (message) {
        if (typeof event.data == "object") {
        } else {
        geojson = null;
        geojson = JSON.parse(message);
        if (layer1added) {
          log("layer removed");
          app.view.removeLayer("building");
        }  
        layer1added = 1;

        _source = new itowns.FileSource({
          fetchedData: geojson,
          crs: 'EPSG:3946',
          format: 'application/json',
        });

        gama_layer = new itowns.FeatureGeometryLayer('building', {
          // Use a FileSource to load a single file once
          source: _source,
          transparent: true,
          opacity: 1,
          style: new itowns.Style({
            fill: {
                  extrusion_height: 10,
                  color: setBuildingColor,
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
  },    10);
}
var _source;

wSocket.onerror = function (event) {
  console.log('An error occurred. Sorry for that.');
}


function onReceiveMsg(e) {
  console.log(e);
  request = "";
}