//
//  Quicksort.swift
//  Party-DJ
//
//  Taken from the Swift Algorithm Club
//  https://github.com/raywenderlich/swift-algorithm-club/tree/master/Quicksort
//

// MARK: - Dutch national flag partitioning
class QuickSort {
    /* Returns a random integer in the range min...max, inclusive. */
    static func random(min: Int, max: Int) -> Int {
        assert(min < max)
        return min + Int(arc4random_uniform(UInt32(max - min + 1)))
    }
    
    /*
     Swift's swap() doesn't like it if the items you're trying to swap refer to
     the same memory location. This little wrapper simply ignores such swaps.
     */
    static func swapWrapper<T>(_ a: inout [T], _ i: Int, _ j: Int) {
        if i != j {
            a.swapAt(i, j)
        }
    }
    
    /*
     Dutch national flag partitioning
     Partitions the array into three sections: all element smaller than the pivot,
     all elements equal to the pivot, and all larger elements.
     This makes for a more efficient Quicksort if the array contains many duplicate
     elements.
     Returns a tuple with the start and end index of the middle area. For example,
     on [0,1,2,3,3,3,4,5] it returns (3, 5). Note: These indices are relative to 0,
     not to "low"!
     The number of occurrences of the pivot is: result.1 - result.0 + 1
     Time complexity is O(n), space complexity is O(1).
     */
    static func partitionDutchFlag<T: Comparable>(_ a: inout [T], low: Int, high: Int, pivotIndex: Int) -> (Int, Int) {
        let pivot = a[pivotIndex]
        
        var smaller = low
        var equal = low
        var larger = high
        
        // This loop partitions the array into four (possibly empty) regions:
        //   [low    ...smaller-1] contains all values < pivot,
        //   [smaller...  equal-1] contains all values == pivot,
        //   [equal  ...   larger] contains all values > pivot,
        //   [larger ...     high] are values we haven't looked at yet.
        while equal <= larger {
            if a[equal] < pivot {
                swapWrapper(&a, smaller, equal)
                smaller += 1
                equal += 1
            } else if a[equal] == pivot {
                equal += 1
            } else {
                swapWrapper(&a, equal, larger)
                larger -= 1
            }
        }
        return (smaller, larger)
    }
    
    /*
     Uses Dutch national flag partitioning and a random pivot index.
     */
    static func quicksortDutchFlag<T: Comparable>(_ a: inout [T], low: Int, high: Int) {
        if low < high {
            let pivotIndex = random(min: low, max: high)
            let (p, q) = partitionDutchFlag(&a, low: low, high: high, pivotIndex: pivotIndex)
            quicksortDutchFlag(&a, low: low, high: p - 1)
            quicksortDutchFlag(&a, low: q + 1, high: high)
        }
    }
}

