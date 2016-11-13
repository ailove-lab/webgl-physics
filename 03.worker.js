var world;
self.onmessage = function(e) {

    if (e.data.cannonUrl && !world) {
        // Load cannon.js
        importScripts(e.data.cannonUrl);

        // Init physics
        world = new CANNON.World();
        world.broadphase = new CANNON.NaiveBroadphase();
        world.gravity.set(0,-10,0);
        world.solver.tolerance = 0.001;

        // Ground plane
        var plane = new CANNON.Plane();
        var groundBody = new CANNON.Body({ mass: 0 });
        groundBody.addShape(plane);
        groundBody.quaternion.setFromAxisAngle(new CANNON.Vec3(1,0,0),-Math.PI/2);
        world.addBody(groundBody);

        // Create N cubes
        var shape = new CANNON.Box(new CANNON.Vec3(1.0, 0.025, 0.5));
        for(var i=0; i!==e.data.N; i++){
            var body = new CANNON.Body({ mass: 1 });
            body.addShape(shape);
            body.position.set(Math.random()-0.5,2.5*i+0.5,Math.random()-0.5);
            world.addBody(body);
        }
    }

    // Step the world
    world.step(e.data.dt);

    // Copy over the data to the buffers
    var positions = e.data.positions;
    var quaternions = e.data.quaternions;
    for(var i=0; i!==world.bodies.length; i++){
        var b = world.bodies[i],
            p = b.position,
            q = b.quaternion;
        positions[3*i + 0] = p.x;
        positions[3*i + 1] = p.y;
        positions[3*i + 2] = p.z;
        quaternions[4*i + 0] = q.x;
        quaternions[4*i + 1] = q.y;
        quaternions[4*i + 2] = q.z;
        quaternions[4*i + 3] = q.w;
    }

    // Send data back to the main thread
    self.postMessage({
        positions:positions,
        quaternions:quaternions
    }, [positions.buffer,
        quaternions.buffer]);
};