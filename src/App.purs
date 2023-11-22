module App where

import Prelude

import Data.Int (toNumber)
import Data.Number (pi)
import React.Basic.Hooks (Component)
import React.Basic.Hooks as Hooks
import React.Basic.Three as D3
import Web.HTML (window)
import Web.HTML.Window as Window

mkApp :: Component Unit
mkApp = do
  window <- window
  innerWidth <- Window.innerWidth window
  innerHeight <- Window.innerHeight window
  let
    camera = D3.perspectiveCamera
      { makeDefault: true
      , fov: 75
      , aspect: toNumber (innerWidth) / toNumber (innerHeight)
      , near: 0.1
      , far: 1000
      , position: [ -3, 8, 2 ]
      }
    dirLight = D3.directionalLight
      { color: "#aaaaaa"
      , position: [ 5, 12, 8 ]
      , intensity: 1.0
      , castShadow: true
      }
    control = D3.orbitControls
      { enablePan: false
      , enableDamping: true
      , dampingFactor: true
      , minDistance: 3
      , maxDistance: 10
      , minPolarAngle: pi / 4.0
      , maxPolarAngle: 3.0 * pi / 4.0
      }
    cube = D3.boxGeometry
      { position: [ -1, 0, 0 ]
      , castShadow: true
      , children:
          [ D3.meshPhongMaterial { attach: "material", args: [ { color: "#0000ff" } ] } ]
      }
    torusKnot = D3.torusKnotGeometry
      { args: [ 0.5, 0.2, 100.0, 100.0 ]
      , position: [ 2, 0, 0 ]
      , castShadow: true
      , children:
          [ D3.meshStandardMaterial { attach: "material", args: [ { color: "#00ff88", roughness: 0.1 } ] } ]
      }
    ground = D3.planeGeometry
      { args: [ 10_000.0, 10_000.0 ]
      , position: [ 0.0, -2.0, 0.0 ]
      , rotation: [ pi / -2.0, 0.0, 0.0 ]
      , receiveShadow: true
      , children:
          [ D3.meshLambertMaterial { attach: "material", args: [ { color: "#ffffff" } ] } ]
      }

  Hooks.component "App" \_ -> Hooks.do
    pure do
      D3.canvas
        { shadows: "soft"
        , camera
        , children:
            [ D3.ambientLight { color: "#666666" }
            , dirLight
            , control
            , cube
            , torusKnot
            , ground
            , D3.stats {}
            ]
        }

