
namespace Blake3

@[extern "blake3_hasher"]
constant Blake3Hasher : Type

@[extern "blake3_hasher_init"]
constant initHasher (b : @& Blake3Hasher) : Blake3Hasher
