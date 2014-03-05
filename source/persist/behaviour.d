module nym.persist.behaviour;

interface IPersist {
  void store(TKey, TValue)(TKey key, TValue value);
}
