class Solution {

    //time complexity O(n) space complexity O(n)

    func twoSum(_ numbers: [Int], _ target: Int) -> [(Int, Int)] {
        var result = Array<(Int, Int)>()
        var helperSet = Set<Int>()
        for i in 0..<numbers.count {
            if !helperSet.contains(target - numbers[i]) {
                helperSet.insert(numbers[i])
            } else {
                result.append((numbers[i], target - numbers[i]))
            }
        }
        return result
    }

    //time complexity O(nLogn) space complexity O(1)

    func twoSumNoSpace(_ numbers: inout [Int], _ target: Int) -> [(Int, Int)] {
        var result = Array<(Int, Int)>()
        numbers = numbers.sorted()
        var startIndex = numbers.startIndex
        var endIndex = numbers.endIndex - 1
        while startIndex < endIndex {
            let sum = numbers[startIndex] + numbers[endIndex]
            if sum == target {
                result.append((numbers[startIndex], numbers[endIndex]))
                startIndex += 1
            } else if sum > target {
                endIndex -= 1
            } else {
                startIndex += 1
            }
        }
        return result
    }
}

let solution = Solution()
var numbers: Array<Int> = [1, 0, 5, 10, 7, -3]
let testTargetOne = 7
let testTargetTwo = 10
var result = solution.twoSum(numbers, 7)
print(result)
numbers = [2, 4, 3, 6, 8, 5]
result = solution.twoSumNoSpace(&numbers, 10)
print(result)
