let project = new Project('MeshLoader');

project.addSources('Sources');
project.addShaders('Sources/Shaders/**');
project.addAssets('Assets/**', {readable: true});

resolve(project);
