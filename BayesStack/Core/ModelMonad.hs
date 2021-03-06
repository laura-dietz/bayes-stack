{-# LANGUAGE FlexibleContexts #-}

module BayesStack.Core.ModelMonad ( ModelMonad(..)
                                  , runModel
                                  , liftRVar, liftRVarT
                                  ) where

import Data.Random.Internal.Source
import qualified Data.Random.Lift
import Data.RVar

import Control.Monad
import Control.Monad.IO.Class
import Control.Applicative

-- | GibbsMonad?
newtype ModelMonad a = ModelMonad { unMM :: (RVarT IO a) }

runModel :: RandomSource IO s => ModelMonad a -> s -> IO a
runModel m s = runRVarT (unMM m) s

instance Functor ModelMonad where
  fmap = liftM
  
instance Monad ModelMonad where
  return x = ModelMonad (return $! x)
  fail s = ModelMonad (fail s)
  (ModelMonad m) >>= k = ModelMonad (m >>= \x -> x `seq` unMM (k x))
  
instance Applicative ModelMonad where
  pure = return
  (<*>) = ap
  
instance MonadIO ModelMonad where
  liftIO = ModelMonad . liftIO
  
instance MonadRandom ModelMonad where
  getRandomPrim = ModelMonad . getRandomPrim
  
liftRVarT :: RVarT IO a -> ModelMonad a
liftRVarT = ModelMonad

liftRVar :: RVar a -> ModelMonad a
liftRVar = ModelMonad . Data.Random.Lift.lift
