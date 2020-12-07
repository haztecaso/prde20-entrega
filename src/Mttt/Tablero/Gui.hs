{-
Module      : Mttt.Tablero.Gui
Copyright   : (c) Adrián Lattes y David Diez
License     : GPL-3
Stability   : experimental

Interfaz gráfica del /meta tres en raya/.
-}

module Mttt.Tablero.Gui where
-- module Mttt.Gui ( 
--     Tema
--   , temaClaro
--   , temaOscuro
--   , guiBoard
-- ) where

import Mttt.Common.Utils 
import Mttt.Common.Gui
import Mttt.Bloque.Gui
import Mttt.Bloque.Data
import Mttt.Tablero.Data

import Data.Array
import Data.Maybe (isJust, fromJust)
import Graphics.Gloss
import Graphics.Gloss.Data.Color
import Graphics.Gloss.Interface.IO.Interact
import Graphics.Gloss.Data.Picture

-- | Tipo que encapsula los datos necesarios para dibujar un 'Tablero' en pantalla
data EstadoTablero = ET { tableroET :: Tablero -- ^ 'Tablero' a dibujar
                       , posET :: Point    -- ^ Posición del centro del tablero
                       , tamET :: Float    -- ^ Tamaño del tablero
                       , temaET :: Tema    -- ^ 'Tema' con el que dibujar el tablero
                       } deriving (Show)

-- | 'EstadoTablero' inicial ('tableroVacio')
eTInicial :: Float -- ^ 'tamET'
          -> Tema  -- ^  'temaET'
          -> EstadoTablero
eTInicial tam tema = 
  ET { tableroET = tableroVacio
     , posET     = (0,0)
     , tamET     = tam
     , temaET    = tema
     }

-- | Dibuja un 'EstadoTablero'
dibujaET :: EstadoTablero -> Picture
dibujaET estado =
  translate (x-tam/2) (y-tam/2) $ pictures $
  [dibujaLineas (0,0) tam $ contraste $ temaET estado]
  ++ [dibujaEB $ estadoBloque pos | pos <- listaIndices]
    where
      (x, y)           = posET estado
      tam              = tamET estado
      tema pos         = temaET estado
      estadoBloque pos =
        EB { bloqueEB = (bloques $ tableroET estado)!pos
           , posEB = posPoint (tam/3) pos
           , tamEB = tam/3*0.8
           , temaEB = tema pos
           }

-- | Modifica el 'EstadoTablero' actual del juego cuando se hace click
modificaET :: Event -> EstadoTablero -> EstadoTablero
modificaET _ estado = estado

-- | Ventana para jugar al meta tres en raya
tableroVentana :: Int -- ^ Tamaño de la ventana
               -> Display
tableroVentana tam = InWindow "Meta tres en raya" (tam, tam) (0,0)

-- | Función IO para pintar un 'EstadoTablero' en pantalla.
-- Tiene la misma interfaz que 'dibujaET'
displayET :: EstadoTablero -> IO ()
displayET estado = display (tableroVentana tam) (fondo $ temaET estado) (dibujaET estado)
  where tam = floor $ 1.15 * (tamET estado)

-- | Función IO para jugar al /meta tres en raya/
guiTablero :: Tema  -- ^ Tema con el que dibujar la interfaz
           -> Float -- ^ Tamaño del tablero
           -> IO ()
guiTablero tema tam = play (tableroVentana tamV) (fondo tema) 15 (eTInicial tam tema) dibujaET modificaET (const id)
  where tamV = floor $ 1.15 * tam