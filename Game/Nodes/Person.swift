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
    var goalDir: [Dir]?                 // The directions to get to the goal
    
    
    // Pathfinding.
    var directions = [Dir]()

    init(walkCycleNamed: String, pos: Pos, type: ObjectType) {
        let rect = CGRect(origin: CGPoint(x: 0.25, y: 0), size: CGSize(width: 0.25, height: 1.0))
        var img = SKTexture(imageNamed: walkCycleNamed)
        img = SKTexture(rect: rect, in: img)
        super.init(img: img, rect: pos.toRect(), type: type)
        anchorPoint = CGPoint(x: 0.5, y: 0)
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func Spawn(from: Object, goal: Object) {
        move(to: from.getPos())
        run(SKAction.fadeIn(withDuration: 1))
        //_ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(Update), userInfo: nil, repeats: true)
    }
    
    public func Despawn() {
        
    }
    
    /** Walk toward the goal. */
    public func walk() {
        
        // If no directions and not next to goal, generate new path.
        if directions.count == 0, let obj = goal {
            if obj.rect.isNextTo(pos: getPos()){
                obj.interact(p: self)
            } else {
                
            }
        } else if directions.count > 0 {
            _ = directions.first!
        }
    }
    
    private func walk(in dir: Dir) {
        print("Tried to walk")
        /*
        switch dir {
        case .north:
            <#code#>
        default:
            <#code#>
        }*/
    }
    
    // 1: up 2: down 3: left 4: right
    // var direction = 0
    var gridPath: [[Int]]!          // Directions toward the goal.
    var stepsLeft = Int.max
    var leastSteps = Int.max            // Idk actually.
    
    public func generatePath(to goal: Object, avoid: [Object]? = nil) {
        self.goal = goal
        let g = goal.rect
        gridPath = Array.init(repeating: Array.init(repeating: 0, count: maxCols), count: maxRows)
        
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
        goalDir = generateDirs(grid: gridPath, start: rect.toPos())
        print(goalDir)
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
        
        // Do the same for every direction
        generatePath(pos: Pos(col: pos.col, row: pos.row + 1), stepsTaken: stepsTaken+1)
        generatePath(pos: Pos(col: pos.col, row: pos.row - 1), stepsTaken: stepsTaken+1)
        generatePath(pos: Pos(col: pos.col + 1, row: pos.row), stepsTaken: stepsTaken+1)
        generatePath(pos: Pos(col: pos.col - 1, row: pos.row), stepsTaken: stepsTaken+1)
        
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
        var value = 0
        
        var lowestNum = Int.max
        var lowestNumDir: Dir = .north
        
        if grid[r][c] == -3 {
            return []
        }
        
        value = grid[r+1][c]
        if (value != -3 && value != -1 && value < lowestNum) {
            lowestNum = value
            lowestNumDir = .north
        }
        value = grid[r][c+1]
        if (value != -3 && value != -1 && value < lowestNum) {
            lowestNum = value
            lowestNumDir = .east
        }
        value = grid[r-1][c]
        if (value != -3 && value != -1 && value < lowestNum) {
            lowestNum = value
            lowestNumDir = .south
        }
        value = grid[r][c-1]
        if (value != -3 && value != -1 && value < lowestNum) {
            lowestNum = value
            lowestNumDir = .west
        }
        
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
    
    /*@objc private func Update() {
        

        
        
        print("path generated")
        
        if isWalking {            
            let rect = CGRect(origin: CGPoint(x: 0 + spriteIndex * 0.25, y: 0),
                              size: CGSize(width: 0.25,
                                           height: 1.0))
            
            texture = SKTexture(rect: rect, in: walkCycle!)
            
            spriteIndex += 1
            if spriteIndex >= 4 { spriteIndex = 0 }
            
            print("updated sprite")
            
            let x = currentPos.row
            let y = currentPos.col
            direction = 0
            
            // Check fastest direction
            checkDirection(row: x, col: y-1, direction: 3)
            checkDirection(row: x, col: y+1, direction: 4)
            checkDirection(row: x-1, col: y, direction: 1)
            checkDirection(row: x+1, col: y, direction: 2)
            
            var action: SKAction!
            
            // Move there       1: up 2: down 3: left 4: right
            switch direction {
            case 1:
                action = SKAction.move(by: CGVector(dx: -40, dy: 20), duration: 0.5)
                currentPos = Pos(col: currentPos.col, row: currentPos.row - 1)
            case 2:
                action = SKAction.move(by: CGVector(dx: 40, dy: -20), duration: 0.5)
                currentPos = Pos(col: currentPos.col, row: currentPos.row + 1)
            case 3:
                action = SKAction.move(by: CGVector(dx: -40, dy: -20), duration: 0.5)
                currentPos = Pos(col: currentPos.col - 1, row: currentPos.row)
            case 4:
                action = SKAction.move(by: CGVector(dx: 40, dy: 20), duration: 0.5)
                currentPos = Pos(col: currentPos.col + 1, row: currentPos.row)
            default:
                // Has arrived at table
                isWalking = false
                
               // targetTable?.used(by: self)
 
                // Set sprite to standing sprite
                let rect = CGRect(origin: CGPoint(x: 0.25, y: 0), size: CGSize(width: 0.25, height: 1.0))
                texture = SKTexture(rect: rect, in: walkCycle!)
                
                removeFromParent()
                return
            }
            
            print("direction: \(direction), stepsLeft: \(stepsLeft), currentPos: \(currentPos)")
            
            self.run(action)
        }
 */
}
    
    

    
    /*
    func Move(to pos: Pos) {
        
        // Move to middle
        anchorPoint = CGPoint(x: 0.5, y: 0)
        position = CGPoint()

        // Move to left edge
        position.x = -80 * 5 + 40

        // Move to correct square
        let offsetPos = CGPoint(x: pos.row * 40 + pos.col * 40 , y: pos.col * 20 - pos.row * 20)
        position.x = position.x + offsetPos.x
        position.y = position.y + offsetPos.y
        
        // Update
    }*/

