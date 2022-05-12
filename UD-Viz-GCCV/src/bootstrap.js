/** @format */

import * as udviz from 'ud-viz';

//itowns
import * as itowns from 'itowns';
export { itowns };



const app = new udviz.Templates.AllWidget();

app.start('../assets/config/config.json').then((config) => {
  app.addBaseMapLayer();

  app.addElevationLayer();

  app.setupAndAdd3DTilesLayers();

  ////// REQUEST SERVICE
  const requestService = new udviz.Components.RequestService();

  ////// ABOUT MODULE
  const about = new udviz.Widgets.AboutWindow();
  app.addModuleView('about', about);

  ////// HELP MODULE
  const help = new udviz.Widgets.Extensions.HelpWindow(config.helpWindow);
  app.addModuleView('help', help);

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

  ////// DOCUMENTS MODULE
  let documentModule = new udviz.Widgets.DocumentModule(
    requestService,
    app.config
  );
  app.addModuleView('documents', documentModule.view);

  ////// DOCUMENTS VISUALIZER EXTENSION (to orient the document)
  const imageOrienter = new udviz.Widgets.DocumentVisualizerWindow(
    documentModule,
    app.view,
    app.controls
  );

  ////// CONTRIBUTE EXTENSION
  new udviz.Widgets.Extensions.ContributeModule(
    documentModule,
    imageOrienter,
    requestService,
    app.view,
    app.controls,
    app.config
  );

  ////// VALIDATION EXTENSION
  new udviz.Widgets.Extensions.DocumentValidationModule(
    documentModule,
    requestService,
    app.config
  );

  ////// DOCUMENT COMMENTS
  new udviz.Widgets.Extensions.DocumentCommentsModule(
    documentModule,
    requestService,
    app.config
  );

  ////// GUIDED TOURS MODULE
  const guidedtour = new udviz.Widgets.GuidedTourController(
    documentModule,
    requestService,
    app.config
  );
  app.addModuleView('guidedTour', guidedtour, {
    name: 'Guided Tours',
  });

  ////// GEOCODING EXTENSION
  const geocodingService = new udviz.Widgets.Extensions.GeocodingService(
    requestService,
    app.extent,
    app.config
  );
  const geocodingView = new udviz.Widgets.Extensions.GeocodingView(
    geocodingService,
    app.controls,
    app.view
  );
  app.addModuleView('geocoding', geocodingView, {
    binding: 's',
    name: 'Address Search',
  });

  ////// CITY OBJECTS MODULE
  let cityObjectModule = new udviz.Widgets.CityObjectModule(
    app.layerManager,
    app.config
  );
  app.addModuleView('cityObjects', cityObjectModule.view);

  ////// LINKS MODULE
  new udviz.Widgets.LinkModule(
    documentModule,
    cityObjectModule,
    requestService,
    app.view,
    app.controls,
    app.config
  );

  ////// 3DTILES DEBUG
  const debug3dTilesWindow = new udviz.Widgets.Extensions.Debug3DTilesWindow(
    app.layerManager
  );
  app.addModuleView('3dtilesDebug', debug3dTilesWindow, {
    name: '3DTiles Debug',
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

var ws = new WebSocket('ws://localhost:6868/');


WebSocket.prototype.sendMessage = function (message) {
  this.send(message);
  console.log('Message sent: ' + message);
}


function log(e) {
  console.log(e);
}
var modelPath = 'C:\\git\\UD_ReAgent_ABM\\ReAgent\\models\\Gratte_Ciel_Basic.gaml';
var experimentName = 'GratteCielErasme';
var species1Name = 'people';
var attribute1Name = 'type';

var geojson;
var marne;





var queue = [];
var a_request = "";
var result = "";
var socket_id = 0;
var exp_id = 0;
var executor_speed = 1;
var executor = setInterval(() => {
  if (queue.length > 0 && a_request === "") {
    a_request = queue.shift();
    a_request.exp_id = exp_id;
    a_request.socket_id = socket_id;
    ws.send(JSON.stringify(a_request));
    log("request " + JSON.stringify(a_request));
    ws.onmessage = function (event) {
      var msg = event.data;
      if (event.data instanceof Blob) { } else {
        if (a_request.callback) {
          a_request.callback(msg);
        } else {
          a_request = "";
        }
      }
    }
  }

}, executor_speed);
ws.onclose = function (event) {
  clearInterval(executor);
};



ws.onopen = function (event) {

  var cmd = {
    "type": "launch",
    "model": modelPath,
    "experiment": experimentName,
    "callback": function (e) {
      log(e);
      result = JSON.parse(e);
      if (result.exp_id) exp_id = result.exp_id;
      if (result.socket_id) socket_id = result.socket_id;
      a_request = "";
    }
  };
  queue.push(cmd);

  cmd = {
    'type': 'output',
    'species': species1Name,
    'attributes': [attribute1Name],
    'socket_id': socket_id,
    'exp_id': exp_id,
    "callback": function (message) {
      if (typeof event.data == "object") {

      } else {
        geojson = null;
        geojson = JSON.parse(message);
        console.log(geojson);
        marne = new itowns.FeatureGeometryLayer('Marne', {
          // Use a FileSource to load a single file once
          source: 
          
          new itowns.FileSource({
            url: 'https://raw.githubusercontent.com/iTowns/iTowns2-sample-data/master/multipolygon.geojson',
            crs: 'EPSG:4326',
            format: 'application/json',
          })
          ,
          transparent: true,
          opacity: 0.7,
          zoom: { min: 10 },
          style: new itowns.Style({
            fill: {
              // color: new itowns.THREE.Color(0xbbffbb),
              extrusion_height: 80,
            }
          })
        });

        app.view.addLayer(marne).then(function menu(layer) {
          var gui = debug.GeometryDebug.createGeometryDebugUI(menuGlobe.gui, view, layer);
          debug.GeometryDebug.addWireFrameCheckbox(gui, view, layer);
        });
        // map.getSource('source1').setData(geojson);

      }
      a_request = "";//IMPORTANT FLAG TO ACCOMPLISH CURRENT TRANSACTION
    }
  };
  queue.push(cmd);

}

ws.onerror = function (event) {
  console.log('An error occurred. Sorry for that.');
}

