module PureShell.Cat.Cat
  ( CatErrors(..)
  , cat
  ) where

import Prelude

import Data.Either (either)
import Node.Path (FilePath)
import PureShell.Common.MonadFS (class MonadFS, exists, readFile, try)

data CatErrors e
  = FileNotReadable FilePath e
  | FileNotExists FilePath

instance showCatErrors :: Show e => Show (CatErrors e) where
  show (FileNotReadable path err) = "Can't read file \"" <> path <> "\" with an error => " <> show err
  show (FileNotExists path) = "Oops bro. FilePath \"" <> path <> "\" doesn't exist"

-- | Nice little technique to emulate Constraint Kinds in Purescript
-- | @see https://github.com/JordanMartinez/purescript-jordans-reference/blob/latestRelease/31-Design-Patterns/07-Simulating-Constraint-Kinds.md
type MonadCat m e r =
  Show e =>
  MonadFS e m =>
  r

-- | The pure version of `cat` by using Constraints
cat :: ∀ m e. MonadCat m e (FilePath -> m String)
cat filePath = do
  fileExists <- exists filePath
  if fileExists
  then do
    result <- try $ readFile filePath
    pure $ either (FileNotReadable filePath >>> show) identity result
  else pure $ show (FileNotExists filePath :: CatErrors e)
