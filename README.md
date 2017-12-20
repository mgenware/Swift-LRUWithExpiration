# Swift-LRUWithExpiration

[![Build Status](https://travis-ci.org/mgenware/Swift-LRUWithExpiration.svg?branch=master)](http://travis-ci.org/mgenware/Swift-LRUWithExpiration)

A Swift LRU with Expiration

## Example
```swift
let lru = LRUWithExpiration<String, Int>(capacity: 2)

lru.setValue(value: 1, forKey: "k1", expire: 3)
lru.setValue(value: 2, forKey: "k2")
// 📭 LRU (capacity: 2): [k2] ⬅️ [k1](expire: 3)

_ = lru["k1"]
// Fetch "k1". Now "k1" becomes more recent than "k2"
// 📭 LRU (capacity: 2): [k1](expire: 3) ⬅️ [k2]

lru.setValue(value: 3, forKey: "k3", expire: 1)
// Add "k3", which will be expired in 1 second
// The least recently used item("k2") is removed since we exceeded the capacity(2).
// 📭 LRU (capacity: 2): [k3](expire: 1) ⬅️ [k1](expire: 3)

// Wait 2 seconds
DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
    print(lru)
    /*
     📭 LRU (capacity: 2): [k1](expire: 3)
     
     Output:
     LRUWithExpiration(Count: 1, Capacity: 2) {
        [k1: 1, expire: 3.0]
     }
     */
}
```