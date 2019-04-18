//
//  Person.swift
//  Game
//
//  Created by Torben Nordtorp on 2018-04-20.
//  Copyright © 2018 Torben Nordtorp. All rights reserved.
//

import SpriteKit

public class Person: Object {
    let walkingSpeed: CGFloat = 0.6
    var spriteIndex: CGFloat = 1
    var goal: Object?                   // This persons current goal object. Nil if none.
    var goalDirs = [Dir]()
    var walkR: [SKTexture] // The directions to get to the goal
    var walkL: [SKTexture] // The directions to get to the goal


    init(walkCycleNamed: String, pos: Pos) {
        walkR = [SKTexture(imageNamed: "guest_walk_1"),
                   SKTexture(imageNamed: "guest_walk_2"),
                   SKTexture(imageNamed: "guest_walk_3"),
                   SKTexture(imageNamed: "guest_walk_2")]
        walkL = [SKTexture(imageNamed: "guest_walk_left_1"),
                 SKTexture(imageNamed: "guest_walk_left_2"),
                 SKTexture(imageNamed: "guest_walk_left_3"),
                 SKTexture(imageNamed: "guest_walk_left_2")]
        walkR = walkR.map({$0.filteringMode = .nearest; return $0})
        walkL = walkL.map({$0.filteringMode = .nearest; return $0})

        super.init(img: walkR[1], rect: pos.toRect())
        anchorPoint = CGPoint(x: 0.5, y: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        walkR = []; walkL = []
        super.init(coder: aDecoder)
    }

    func Spawn(from: Object, goal: Object) {
        move(to: from.pos)
        run(SKAction.fadeIn(withDuration: 1))
    }
    
    /** Walk toward the goal. */
    public func walk(to goal: Object, avoid: [Object]? = nil) {
        generatePath(to: goal, avoid: avoid)
        walk()
    }
    private func walk() {
        // If no directions and not next to or already at goal, generate new path.
        if let obj = goal as? Chair, goalDirs.count == 0 {
            if (obj.rect.isNextTo(pos: pos) != nil) {
                print("Framme!")
                if obj.person == nil {
                    obj.sitDown(prs: self)
                } else {
                    goal = nil
                }
            }
        } else if goalDirs.count > 0 {
            var vector = CGVector()
            var isWalkingRight = true
            switch goalDirs.removeFirst() {
            case .north:
                vector = CGVector(dx: gridWidth/2, dy: gridHeight/2)
                pos += Pos(col: 0, row: 1)
            case .east:
                vector = CGVector(dx: gridWidth/2, dy: -gridHeight/2)
                pos += Pos(col: 1, row: 0)
            case .south:
                vector = CGVector(dx: -gridWidth/2, dy: -gridHeight/2)
                pos += Pos(col: 0, row: -1)
                isWalkingRight = false
            case .west:
                vector = CGVector(dx: -gridWidth/2, dy: gridHeight/2)
                pos += Pos(col: -1, row: 0)
                isWalkingRight = false
            }
            
            let textures = isWalkingRight ? walkR : walkL
            let ani = SKAction.animate(with: textures, timePerFrame: 0.2)
            let move = SKAction.move(by: vector, duration: 0.8)
            removeAllActions()
            run(.group([ani, move])) {
                self.walk()
            }
        }
    }
    
    var gridPath: [[Int]]!              // Directions toward the goal.
    var stepsLeft = Int.max
    var leastSteps = Int.max            // Idk actually.
    
    private func generatePath(to goal: Object, avoid: [Object]? = nil) {
        self.goal = goal
        let g = goal.rect
        gridPath = Array.init(repeating: Array.init(repeating: 0, count: maxCols), count: maxRows)
        leastSteps = Int.max
        stepsLeft = Int.max
        
        // Puts -1 where you can't go
        if let objs = avoid {
            for obj in objs {
                for x in obj.rect.rowRange {
                    for y in obj.rect.colRange {
                        gridPath[x][y] = -1
                    }
                }
            }
        }
        
        // Put -2 where you are
        gridPath[rect.row][rect.col] = -2
        
        // Puts -3 where the goal object is
        for x in g.rowRange {
            for y in g.colRange {
                gridPath[x][y] = -3
            }
        }
        
        // Generate a path
        for x in g.rowRange {
            for y in g.colRange {
                // Check every possible direction to walk in and save the steps it took to get there
                generatePath(pos: Pos(col: y, row: x + 1), stepsTaken: 1)
                generatePath(pos: Pos(col: y, row: x - 1), stepsTaken: 1)
                generatePath(pos: Pos(col: y + 1, row: x), stepsTaken: 1)
                generatePath(pos: Pos(col: y - 1, row: x), stepsTaken: 1)
            }
        }
        
        for r in gridPath!.indices {
            debugPrint(gridPath![r])
        }
        
        // Save that path as directions
        goalDirs = generateDirs(grid: gridPath, start: pos).dropLast()
        print(goalDirs as Any)
    }
    private func generatePath(pos: Pos, stepsTaken: Int) {
        
        if stepsTaken > leastSteps { return }
        
        // If position exisits in grid...
        if gridPath.indices.contains(pos.row) && gridPath[pos.row].indices.contains(pos.col)
        {
            let value = gridPath[pos.row][pos.col]
            
            // If goal, update least steps, 
            if value < 0 {
                if value == -2 {
                    if stepsTaken < leastSteps {
                        leastSteps = stepsTaken
                    }
                }
                return
            } else if value == 0 || stepsTaken < value {
                // ...write current step count in this position.
                gridPath[pos.row][pos.col] = stepsTaken
            }
            else { return }
        }
        else { return }
        
        let nextToPos = [
            Pos(col: 0, row: 1),
            Pos(col: 0, row: -1),
            Pos(col: 1, row: 0),
            Pos(col: -1, row: 0)]
        
        for pos2 in nextToPos {
            let pos3 = pos + pos2
            if pos3.row < maxRows && pos3.row >= 0 && pos3.col < maxCols && pos3.col >= 0 {
                generatePath(pos: pos3, stepsTaken: stepsTaken+1)
            }
        }
        
        /*
         This should produce a grid looking a bit like this
         [
         [4,  3,  2,  1, 0],
         [5, -2, -2,  2, 1],
         [6, -1,  6, -2, 4],
         [7,  6,  5,  4, 3]
         ]
         
         where -2 is a wall, x is current position and -1 is the goal. I think.
         
         To find back you need to take the lowest number and reach 0.
         */
    }
    private func generateDirs(grid: [[Int]], start: Pos) -> [Dir] {
        let r = start.row
        let c = start.col
        let rMax = grid.count
        let cMax = grid[0].count

        var value = grid[r][c]
        
        var lowestNum = Int.max
        var lowestNumDir: Dir = .north
        
        // If you reached the goal, return.
        if value == -3 {
            return []
        }
        
        if r+1 < rMax {
            value = grid[r+1][c]
            if value <= 0 && value != -3 { }
            else
            if value != -1 && value < lowestNum {
                lowestNum = value
                lowestNumDir = .north
            }
        }
        
        if c+1 < cMax {
            value = grid[r][c+1]
            if value <= 0 && value != -3 { }
            else
            if value != -1 && value < lowestNum {
                lowestNum = value
                lowestNumDir = .east
            }
        }
        
        if r-1 >= 0 {
            value = grid[r-1][c]
            if value <= 0 && value != -3 { }
            else
            if value != -1 && value < lowestNum {
                lowestNum = value
                lowestNumDir = .south
            }
        }
            
        if c-1 >= 0 {
            value = grid[r][c-1]
            if value <= 0 && value != -3 { }
            else
            if value != -1 && value < lowestNum {
                lowestNum = value
                lowestNumDir = .west
            }
        }
        
        if value == Int.max { fatalError("Pathfinding did not result in a complete path.") }
        
        var arr = [Dir]()
        
        switch lowestNumDir {
        case .north:
            arr = [Dir.north]
            arr.append(contentsOf: generateDirs(grid: grid, start: Pos(col: c, row: r + 1)))
        case .east:
            arr = [Dir.east]
            arr.append(contentsOf: generateDirs(grid: grid, start: Pos(col: c + 1, row: r )))
        case .south:
            arr = [Dir.south]
            arr.append(contentsOf: generateDirs(grid: grid, start: Pos(col: c, row: r - 1)))
        case .west:
            arr = [Dir.west]
            arr.append(contentsOf: generateDirs(grid: grid, start: Pos(col: c - 1, row: r)))
        }
        return arr
    }
}
