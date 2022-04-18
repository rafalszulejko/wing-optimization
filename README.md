## Double element wing optimization using machine learning and a genetic algorithm

This is my undergraduate Computer Science thesis project at the Electrical Engineering faculty at Warsaw University of Technology.

### Description

This project is largely an attempt at reverse-engineering and replicating the results of work by Dr Josef Dubsky and Dr Christos Pashias on Porsche 919 Evo rear wing optimization published in a [non-technical Medium article](https://medium.com/next-level-german-engineering/how-machine-learning-transformed-the-porsche-919-hybrid-evo-33d9881cb0e5). Being an undergraduate thesis, the time was limited and results are mostly there for the sake of showing a proof of concept. Next version of the project will hopefully be more usable.

The pipeline of this project is as following - the MATLAB's autoencoder is trained on nodes/thicknesses probed on most airfoils from UIUC Selig airfoil database. The encoder part is tossed away, and decoder is used as a generator of new nodes, which are later interpolated with a spline. This generator is then used in a MATLAB's genetic algorithm, where a fitness function is calculated by generating two of such airfoils, meshing them in gmsh and calculating CL and CD in OpenFOAM.

### Running:
Run this code at your own risk, it's barely working. The main function is `findParams`. If you don't have a pretrained autoencoder at hand, use `generator/train_selig` or `generator/train_selig_new`.

#### Requirements: 
- MATLAB(with several toolboxes)
- OpenFOAM v8
- gmsh 4.9.1

### Project state
This project is (hopefully) under further development in a [new repository](https://github.com/rafalszulejko/wing-optimization2). This is due to the fact that I intend to change the tech stack quite a bit, and I also want to preserve this repository in a state in which I finished my undergraduate thesis.

---

Special thanks to [@bchaber](https://github.com/bchaber) for putting up with _a lot_ of emails from me and being a great thesis advisor in general!
