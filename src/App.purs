module App where

import Prelude

import Data.Function.Uncurried (mkFn3)
import Data.Int (toNumber)
import Data.Number (abs, cos, pi, sin)
import Data.Tuple.Nested ((/\))
import Effect.Uncurried (runEffectFn1, runEffectFn2)
import React.Basic (empty)
import React.Basic.Hooks (Component, useRef, useState)
import React.Basic.Hooks as Hooks
import React.Basic.R3F (LilGUIProperty(..))
import React.Basic.R3F as R3F
import React.Basic.R3F.Hooks (useFrame)
import React.Basic.R3F.Types (setPosition, setRotation)
import Web.HTML (window)
import Web.HTML.Window as Window

mkApp :: Component Unit
mkApp = do
  window <- window
  innerWidth <- Window.innerWidth window
  innerHeight <- Window.innerHeight window

  fog <- runEffectFn1 R3F.createFog { color: "#ffffff", near: 0.0025, far: 50.0 }
  scene <- runEffectFn1 R3F.createScene fog

  let
    camera = R3F.perspectiveCamera
      { makeDefault: true
      , fov: 75
      , aspect: toNumber (innerWidth) / toNumber (innerHeight)
      , near: 0.1
      , far: 1000
      , position: [ -3, 2, 8 ]
      }
    dirLight = R3F.directionalLight
      { color: "#aaaaaa"
      , position: [ 5, 12, 8 ]
      , intensity: 1.0
      , castShadow: true
      }
    control = R3F.orbitControls
      { enablePan: false
      , enableDamping: true
      , dampingFactor: true
      , minDistance: 3
      , maxDistance: 10
      , minPolarAngle: pi / 4.0
      , maxPolarAngle: 3.0 * pi / 4.0
      }
    ground = R3F.planeGeometry
      { args: [ 10_000.0, 10_000.0 ]
      , position: [ 0.0, -2.0, 0.0 ]
      , rotation: [ pi / -2.0, 0.0, 0.0 ]
      , receiveShadow: true
      , children:
          [ R3F.meshLambertMaterial { attach: "material", args: [ { color: "#ffffff" } ] } ]
      }

  let
    props = { cubeSpeed: 0.01, torusSpeed: 0.01 }

  gui <- R3F.lilGUICreate
  R3F.lilGUIAdd gui props "cubeSpeed" $ NumberField (-0.2) 0.2 0.01
  R3F.lilGUIAdd gui props "torusSpeed" $ NumberField (-0.2) 0.2 0.01

  -- Here it demonstrates how to do basic animation by changing a component's
  -- position and rotation.
  --
  -- In order to do that in `@react-three/fiber`, one has to use its specific
  -- `useFrame` hook. Inside the hook's callback function, the properties of the
  -- target component must be manipulated not directly but through a react
  -- `ref`, which also has to be assigned to the target component's ref
  -- property.
  cube <- Hooks.component "cube" \_ -> Hooks.do
    ref <- useRef empty
    step /\ setStep <- useState 0.0

    useFrame $ const $ const do
      setStep (_ + 0.04)
      runEffectFn2 setPosition ref
        $ mkFn3 \_ _ z -> [ 4.0 * cos step, 4.0 * abs (sin step), z ]
      runEffectFn2 setRotation ref
        $ mkFn3 \x y z -> map (_ + props.cubeSpeed) [ x, y, z ]
    pure do
      R3F.boxGeometry
        { ref: ref
        , position: [ -1.0, 0.0, 0.0 ]
        , castShadow: true
        , children:
            [ R3F.meshPhongMaterial { attach: "material", args: [ { color: "#0000ff" } ] } ]
        }

  torusKnot <- Hooks.component "torusKnot" \_ -> Hooks.do
    ref <- useRef empty

    useFrame $ const $ const do
      let speed = props.torusSpeed
      runEffectFn2 setRotation ref
        $ mkFn3 \x y z -> [ x - speed, y + speed, z - speed ]
    pure do
      R3F.torusKnotGeometry
        { ref: ref
        , args: [ 0.5, 0.2, 100.0, 100.0 ]
        , position: [ 2, 0, 0 ]
        , castShadow: true
        , children:
            [ R3F.meshStandardMaterial { attach: "material", args: [ { color: "#00ff88", roughness: 0.1 } ] } ]
        }

  Hooks.component "App" \_ -> Hooks.do
    pure do
      R3F.canvas
        { shadows: "soft"
        , scene
        , children:
            [ camera
            , R3F.ambientLight { color: "#666666" }
            , dirLight
            , control
            , cube {}
            , torusKnot {}
            , ground
            , R3F.stats
            ]
        }

