
# three var
camera    = undefined
scene     = undefined
light     = undefined
renderer  = undefined
canvas    = undefined
controls  = undefined
meshs     = []
grounds   = []
isMobile  = false
antialias = true
green     = 0x008356
geos = {}
mats = {}

#oimo var
world = null
bodys = []
fps   = [0, 0, 0, 0]
ToRad = 0.0174532925199432957
type  = 1
infos = undefined
rnd   = Math.random
SC    = 1.0


init = ->
    
    n = navigator.userAgent
    
    if n.match(/Android/i) or n.match(/webOS/i) or n.match(/iPhone/i) or n.match(/iPad/i) or n.match(/iPod/i) or n.match(/BlackBerry/i) or n.match(/Windows Phone/i)
        isMobile = true
        antialias = false

    infos  = document.getElementById('info'  )
    canvas = document.getElementById('canvas')
    
    camera = new THREE.PerspectiveCamera(60, window.innerWidth / window.innerHeight, 1, SC*5000)
    
    camera.position.set SC*160, SC*200, SC*200
    controls = new THREE.OrbitControls(camera, canvas)
    controls.target.set 0, SC*20, 0
    controls.update()
    scene = new THREE.Scene
    
    renderer = new THREE.WebGLRenderer(
        canvas: canvas
        precision: 'mediump'
        antialias: antialias)
    
    renderer.setSize window.innerWidth, window.innerHeight
    materialType = 'MeshBasicMaterial'
    
    if !isMobile
        scene.add new THREE.AmbientLight(0x3D4143)
        light = new THREE.DirectionalLight(0xffffff, 1.4)
        light.position.set SC*300, SC*1000, SC*500
        light.target.position.set 0, 0, 0
        light.castShadow = true
        light.shadowCameraNear = SC*500
        light.shadowCameraFar = SC*1600
        light.shadowCameraFov = 70
        light.shadowBias = 0.0001
        light.shadowDarkness = 0.7
        light.shadowCameraVisible = true;
        light.shadowMapWidth = light.shadowMapHeight = 1024
        scene.add light
        
        materialType = 'MeshPhongMaterial'
        renderer.shadowMap.enabled = true
        renderer.shadowMap.type = THREE.PCFShadowMap

        #THREE.BasicShadowMap;
    
    # background
    buffgeoBack = new THREE.BufferGeometry
    buffgeoBack.fromGeometry new THREE.IcosahedronGeometry(SC*3000, 2)
    back = new THREE.Mesh(buffgeoBack, new THREE.MeshBasicMaterial(
        map: gradTexture([
            [0.75,0.6,0.4,0.25]
            ['#008356','#008356','#FFFFFF','#FFFFFF']
        ])
        side: THREE.BackSide
        depthWrite: false
        fog: true))

    #back.geometry.applyMatrix(new THREE.Matrix4().makeRotationZ(15*ToRad));
    scene.add back
    
    # geometrys
    geos['box'] = (new THREE.BufferGeometry).fromGeometry(new THREE.BoxGeometry(1, 1, 1))
    
    # materials
    mats['box'] = new (THREE[materialType])(
        shininess: 10
        map: basicTexture(2)
        name: 'box')

    mats['sbox'] = new (THREE[materialType])(
        shininess: 10
        map: basicTexture(3)
        name: 'sbox')

    mats['ground'] = new (THREE[materialType])(
        shininess: 10
        color: 0x111111
        transparent: true
        opacity: 0.5)

    # events
    window.addEventListener 'resize', onWindowResize, false
    document.addEventListener 'keyup', onKey, false

    # physics
    initOimoPhysics()



main_loop = ->
    updateOimoPhysics()
    renderer.render scene, camera
    requestAnimationFrame main_loop



onWindowResize = ->
    camera.aspect = window.innerWidth / window.innerHeight
    camera.updateProjectionMatrix()
    renderer.setSize window.innerWidth, window.innerHeight


onKey = (e)->
    if e.key is " "
        add_new_card()


addStaticBox = (size, position, rotation) ->
    mesh = new THREE.Mesh(geos.box, mats.ground)
    mesh.scale.set size[0], size[1], size[2]
    mesh.position.set position[0], position[1], position[2]
    mesh.rotation.set rotation[0] * ToRad, rotation[1] * ToRad, rotation[2] * ToRad
    scene.add mesh
    grounds.push mesh
    mesh.castShadow = true
    mesh.receiveShadow = true


clearMesh = ->
    i = meshs.length
    while i--
        scene.remove meshs[i]
    i = grounds.length
    while i--
        scene.remove grounds[i]
    grounds = []
    meshs = []


#----------------------------------
#  OIMO PHYSICS
#----------------------------------

initOimoPhysics = ->
    # world setting:( TimeStep, BroadPhaseType, Iterations )
    # BroadPhaseType can be 
    # 1 : BruteForce
    # 2 : Sweep and prune , the default 
    # 3 : dynamic bounding volume tree
    world = new OIMO.World(1 / 60, 2, 32)
    # gravity 1.0
    # world.worldscale 1000
    populate()
    #setInterval(updateOimoPhysics, 1000/60);


populate = ->

    max = 20

    # reset old
    clearMesh()
    world.clear()
    bodys = []
    
    #add ground
    # ground0 = world.add(
    #     size: [40, 40, 390]
    #     pos: [-180, 20, 0]
    #     world: world)
    
    # ground1 = world.add(
    #     size: [40, 40, 390]
    #     pos: [180, 20,0]
    #     world: world)

    table = world.add
        size : [SC*400, SC*80,SC*400]
        pos  : [  0,-SC*40,  0]
        world: world
    
    phone = world.add
        size : [SC*100, SC*20, SC*180]
        pos  : [  0, SC*20,   0]
        world: world

    # addStaticBox [  40, 40, 390], 
    #              [-180, 20,   0], 
    #              [   0,  0,   0]

    # addStaticBox [ 40, 40, 390], 
    #              [180, 20,   0], 
    #              [  0,  0,   0]

    # table
    # addStaticBox [400, 80, 400], 
    #              [  0,-40,   0], 
    #              [  0,  0,   0]
    
    # phone    
    addStaticBox [ SC*100, SC*20, SC*180], 
                 [   0, SC*20,   0], 
                 [   0,  0,   0]
    

add_new_card = ->
    
    x = (rnd()-rnd()) * SC*10
    z = (rnd()-rnd()) * SC*10
    y = SC*200
    
    w = SC*50
    h = SC* 2
    d = SC*90

    body = world.add(
        type: 'box'
        size: [w, h, d]
        pos:  [x, y, z]
        rot:  [(rnd()-rnd())*15,(rnd()-rnd())*45,(rnd()-rnd())*15]
        move: true
        config: [
            1.0,         # The density of the shape.
            0.4,       # The coefficient of friction of the shape.
            0.0,       # The coefficient of restitution of the shape.
            1,         # The bits of the collision groups to which the shape belongs.
            0xffffffff # The bits of the collision groups with which the shape collides.
        ]
        world: world)
    bodys.push body

    mesh = new THREE.Mesh(geos.box, mats.box)
    mesh.scale.set w, h, d
    mesh.quaternion.copy body.getQuaternion()

    # mesh.rotation.set (rnd()-rnd()),(rnd()-rnd()),(rnd()-rnd())
    
    mesh.castShadow = false
    mesh.receiveShadow = false
    
    meshs.push mesh
    scene.add mesh


updateOimoPhysics = ->
    
    if world == null
        return
    
    world.step()
    
    i = bodys.length

    while i--
        body = bodys[i]
        mesh = meshs[i]
        
        if !body.sleeping
            
            mesh.position.copy body.getPosition()
            mesh.quaternion.copy body.getQuaternion()
            
            # change material
            if mesh.material.name == 'sbox'
                mesh.material = mats.box
            
            # reset position
            if mesh.position.y < -100
                x = (rnd()-rnd()) * SC*   10
                z = (rnd()-rnd()) * SC*   10
                y =  100 + rnd()  * SC* 1000

                body.resetPosition x, y, z
                body.resetRotation 0, 0, 0
        # sleep
        else
            if mesh.material.name == 'box'
                mesh.material = mats.sbox

    infos.innerHTML = world.performance.show()


gravity = (g) ->
    world.gravity = new (OIMO.Vec3)(0, -g, 0)

#----------------------------------
#  TEXTURES
#----------------------------------


gradTexture = (color) ->
    c = document.createElement('canvas')
    ct = c.getContext('2d')
    size = 1024
    c.width = 16
    c.height = size
    gradient = ct.createLinearGradient(0, 0, 0, size)
    i = color[0].length
    while i--
        gradient.addColorStop color[0][i], color[1][i]
    ct.fillStyle = gradient
    ct.fillRect 0, 0, 16, size
    texture = new (THREE.Texture)(c)
    texture.needsUpdate = true
    texture


basicTexture = (n) ->
    `var canvas`
    canvas = document.createElement('canvas')
    canvas.width = canvas.height = 64
    ctx = canvas.getContext('2d')
    color = undefined
    if n == 0
        color = '#3884AA'
    # sphere58AA80
    if n == 1
        color = '#61686B'
    # sphere sleep
    if n == 2
        color = '#CCCCCC'
    # box
    if n == 3
        color = '#AAAAAA'
    # box sleep
    if n == 4
        color = '#AAAA38'
    # cyl
    if n == 5
        color = '#61686B'
    
    # cyl sleep
    ctx.fillStyle = color
    ctx.fillRect 0, 0, 64, 64
    ctx.fillStyle = 'rgba(0,0,0,0.2)'
    ctx.fillRect 0, 0, 32, 32
    ctx.fillRect 32, 32, 32, 32
    tx = new THREE.Texture(canvas)
    tx.needsUpdate = true
    tx


init()
main_loop()
