# wing-optimization
Double element wing optimization using machine learning and genetic algorithm.
Based on the article by Josef Dubsky and Dr Christos Pashias:
https://medium.com/next-level-german-engineering/how-machine-learning-transformed-the-porsche-919-hybrid-evo-33d9881cb0e5

Requirements: MATLAB, OpenFOAM v8, gmsh 4.9.0-git-ccae7b60e lub higher (confirmed not working on 4.8.4).

## In progress:
- Case calculation. Currently using double NACA as proof-of-concept placeholder.
    - OpenFOAM setup
    - mesh generation

## To do:
- General airfoil generator
- Optimization algorithm