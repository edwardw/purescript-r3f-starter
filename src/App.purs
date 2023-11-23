module App where

import Prelude

import Data.Int (toNumber)
import Data.Number (pi)
import React.Basic.Hooks (Component)
import React.Basic.Hooks as Hooks
import React.Basic.R3F as R3F
import Web.HTML (window)
import Web.HTML.Window as Window

mkApp :: Component Unit
mkApp = do
  window <- window
  innerWidth <- Window.innerWidth window
  innerHeight <- Window.innerHeight window
  let
    camera = R3F.perspectiveCamera
      { makeDefault: true
      , fov: 75
      , aspect: toNumber (innerWidth) / toNumber (innerHeight)
      , near: 0.1
      , far: 1000
      , position: [ -3, 8, 2 ]
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
    cube = R3F.boxGeometry
      { position: [ -1.0, 0.0, 0.0 ]
      , rotation: [ 0.0, 0.0, 0.0]
      , castShadow: true
      , children:
          [ R3F.meshPhongMaterial { attach: "material", args: [ { color: "#0000ff" } ] } ]
      }
    torusKnot = R3F.torusKnotGeometry
      { args: [ 0.5, 0.2, 100.0, 100.0 ]
      , position: [ 2, 0, 0 ]
      , castShadow: true
      , children:
          [ R3F.meshStandardMaterial { attach: "material", args: [ { color: "#00ff88", roughness: 0.1 } ] } ]
      }
    ground = R3F.planeGeometry
      { args: [ 10_000.0, 10_000.0 ]
      , position: [ 0.0, -2.0, 0.0 ]
      , rotation: [ pi / -2.0, 0.0, 0.0 ]
      , receiveShadow: true
      , children:
          [ R3F.meshLambertMaterial { attach: "material", args: [ { color: "#ffffff" } ] } ]
      }

  Hooks.component "App" \_ -> Hooks.do
    pure do
      R3F.canvas
        { shadows: "soft"
        , camera
        , children:
            [ R3F.ambientLight { color: "#666666" }
            , dirLight
            , control
            , cube
            , torusKnot
            , ground
            , R3F.stats {}
            ]
        }

