-- |
-- Module      : Mttt.Bloque.Gui
-- Copyright   : (c) Adrián Lattes y David Diez
-- License     : GPL-3
-- Stability   : experimental
--
-- Interfaz gráfica del /tres en raya/.
module Mttt.Bloque.Gui
  ( EstadoBloque (EB, bloqueEB, centroEB, tamEB, temaEB),
    estadoBloqueInicial,
    guiAgenteBloque,
  )
where

import Data.Maybe (fromJust, isJust)
import Graphics.Gloss (Picture (Blank), Point, color, pictures, play)
import Mttt.Bloque.Data
import Mttt.Common.Data
import Mttt.Common.Gui

-- | Tipo que encapsula los datos necesarios para dibujar un 'Bloque' en pantalla
data EstadoBloque = EB
  { -- | 'Bloque' a dibujar
    bloqueEB :: Bloque,
    -- | Posición del centro del tablero
    centroEB :: Point,
    -- | Tamaño del tablero
    tamEB :: Float,
    -- | 'Tema' con el que dibujar el tablero
    temaEB :: Tema
  }
  deriving (Show)

instance Estado EstadoBloque where
  tam = tamEB
  centro = centroEB
  tema = temaEB

  dibuja e = pictures $ [dibujaCasilla pos | pos <- listaIndices]
    where
      dibujaCasilla pos
        | isJust casilla' = dibujaFicha (modTema e) (tam e * 0.2) origen (fromJust casilla')
        | otherwise = Blank
        where
          casilla' = casilla (bloqueEB e) pos
          origen = posPoint (tam e / 3) pos

  modifica p e
    | isJust nuevo = e {bloqueEB = fromJust nuevo}
    | fin b = e {bloqueEB = bloqueVacio}
    | otherwise = e
    where
      b = bloqueEB e
      nuevo = mov b $ pointPos p (tam e) (centro e)

-- | Función para construir un 'EstadoBloque' con un 'bloqueVacio'tableroVacio'
estadoBloqueInicial ::
  -- | Tamaño
  Float ->
  Tema ->
  EstadoBloque
estadoBloqueInicial tam tema =
  EB
    { bloqueEB = bloqueVacio,
      centroEB = (0, 0),
      tamEB = tam,
      temaEB = tema
    }

-- | Pintar el ganador de la partida. Estaría bien que se pinten solo las
--  casillas ganadoras.
modTema ::
  EstadoBloque ->
  Tema
modTema estado
  | ganador b == Just X = t {secundario = n}
  | ganador b == Just O = t {principal = n}
  | tablas b = t {secundario = n, principal = n}
  | otherwise = t
  where
    b = bloqueEB estado
    t = temaEB estado
    n = neutro t

-- | Función que ejecuta la jugada de un 'Agente Bloque'.
modificaEstadoBloqueAgente ::
  -- | 'AgenteBloque' con el que calcular la jugada
  Agente Bloque ->
  -- | 'Ficha' del 'AgenteBloque'
  Ficha ->
  -- | Frame actual del juego (parámetro ignorado)
  Float ->
  -- | Estado actual del tablero
  EstadoBloque ->
  EstadoBloque
modificaEstadoBloqueAgente agente fichaAgente _ estado =
  if turno b == Just fichaAgente && not (fin b)
    then (estado {bloqueEB = f agente b})
    else estado
  where
    b = bloqueEB estado

-- | Función IO para jugar al /tres en raya/ contra un agente
guiAgenteBloque ::
  -- | Estado inicial
  EstadoBloque ->
  -- | 'Ficha' del 'Agente'
  Ficha ->
  -- | 'Agente' contra el que jugar
  Agente Bloque ->
  IO ()
guiAgenteBloque = guiAgente modificaEstadoBloqueAgente
