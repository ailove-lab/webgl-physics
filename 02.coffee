demo = new CANNON.Demo

rnd = ->(Math.random()-Math.random())/2.0

demo.addScene 'test', ->

    world = demo.getWorld()
    # world.allowSleep = true;
    world.gravity.set 0, 0, -5
    world.broadphase = new CANNON.NaiveBroadphase
    world.solver.iterations = 50
    world.defaultContactMaterial.contactEquationStiffness = 5e6
    world.defaultContactMaterial.contactEquationRelaxation = 3


    # ground plane
    groundShape = new CANNON.Plane

    groundBody = new CANNON.Body(mass: 0)
    groundBody.addShape groundShape
    groundBody.position.set -10, 0, 0
    world.addBody groundBody
    demo.currentMaterial =  new THREE.MeshLambertMaterial( { color: 0x008356 } );
    demo.addVisual groundBody

    # groundShape.material = ground_material


    mass = 1
    w = 9.0
    h = 5.0
    d = 0.1
    s = 0.5

    # phone

    phoneBody  = new CANNON.Body mass: 0
    size = new CANNON.Vec3 h*s*2.0, w*s*2.0, h/5.0*s
    phoneShape = new CANNON.Box size
    phoneBody.addShape phoneShape
    phoneBody.position.set 0, 0, h/5.0*s
    
    world.addBody phoneBody
    demo.currentMaterial =  new THREE.MeshLambertMaterial( { color: 0x111111 } );
    demo.addVisual phoneBody


    demo.currentMaterial =  new THREE.MeshLambertMaterial( { color: 0xEEEEEE } );
    i = 0
    while i < 20

        # Layers
        body = new CANNON.Body mass: mass
        size = new CANNON.Vec3 h*s, w*s, d*s

        shape = new CANNON.Box size
        body.addShape shape
        body.position.set rnd()*5.0, rnd()*5.0, i*2.0 + 5  
        body.quaternion.setFromEuler rnd()/2.0, rnd()/2.0, rnd()/2.0, "XYZ"     
        world.addBody body
        demo.addVisual body

        i++

demo.start()