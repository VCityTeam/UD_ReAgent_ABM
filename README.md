# UD_ReAgent_ABM
Agent Based Simulation framework for Urban Data Services and Vizualisation.

See the [wiki](https://github.com/VCityTeam/UD_ReAgent_ABM/wiki) for more information about this project

Contact: Arnaud Grignard 

This repository contain two main projects

## ReAgent
ABM model developped using [Gama Platform](https://gama-platform.org/). As a standalone can be used directly to be displayed on a physical table. 

- In Gama 1.8.2 Import the project ```ReAgent```
- Open ```Gratte_Ciel_demo.gaml```
- Run ```Demo```


## UD-Viz-GCCV
- ``` cd UD-Viz-GCCV ```
- ``` npm i ```
- ```npm run debug ```
- Open a browser at this adress ``` http://localhost:8000/ ```

### For the Streaming version you will need to run GAMA in headless as a server to do so

- ``` cd Gama.app/Contents/headless ```
- ``` bash gama-headless.sh -socket 6868 ```

NB: Be sure to update the local path by changing the local variable ```modelPath``` in ```bootstrap.js```to the GAMA model (by default const modelPath = '/Users/arno/Projects/GitHub/UD_ReAgent_ABM/ReAgent/models/Gratte_Ciel_Demo.gaml';
