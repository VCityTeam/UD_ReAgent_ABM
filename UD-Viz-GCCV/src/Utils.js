/**
 *
 */
export class Utils {
  /**
   *
   * @param {*} name
   * @param {*} configLayer
   */
  constructor() {}

  /**
   * toc toc, who is there ?
   */
  foo() {
    console.log("ok je susi appelleé de l'exterieur");
  }

  setPeopleColor(properties) {
    if (properties.type === "car") {
      return "red"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "bike") {
      return "green"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "pedestrian") {
      return "blue"; // new itowns.THREE.Color(0xaaaaaa);
    }
  }

  setBuildingColor(properties) {
    if (properties.type === "apartments") {
      return "blue"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "school") {
      return "green"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "construction") {
      return "yellow"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "civic") {
      return "orange"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "church") {
      return "white"; // new itowns.THREE.Color(0xaaaaaa);
    }
    if (properties.type === "service") {
      return "pink"; // new itowns.THREE.Color(0xaaaaaa);
    }
    return "blue";
  }

  setRoadColor(properties) {
    if (properties.type === "road") {
      return "white"; // new itowns.THREE.Color(0xaaaaaa);
    }
    return "blue";
  }
}
