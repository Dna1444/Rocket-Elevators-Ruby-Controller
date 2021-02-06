module ResidentialController 
    @door_id = 1

    #my column class
    class Column 

        def initialize( _id, _status, _amountOfFloors, _amountOfElevator)
            @elevator_list = []
            @call_button_list = []
            @ID = _id
            @status = _status
            @amountOfFloors = _amountOfFloors
            @amountOfElevators = _amountOfElevator

            self.createCallButtons(_amountOfFloors)
            self.createElevators(_amountOfElevator, _amountOfFloors)
        end

        def getElevatorList
            @elevator_list
        end
    # method for making my call buttons
        def createCallButtons( _amountOfFloors)
            number_of_floor = _amountOfFloors
            button_floor = 1
            call_button_id = 1
            
            for button_floor in 1..number_of_floor
                if button_floor < _amountOfFloors
                    call_button = CallButton.new(call_button_id, "off", button_floor, "up")
                    @call_button_list.push(call_button)
                    call_button_id += 1
                end
                if button_floor > 1
                call_button = CallButton.new(call_button_id, "off", button_floor, "down")
                @call_button_list.push(call_button)
                call_button_id += 1
                
                button_floor += 1
                end
            end
        end
    # method for making my elevators
        def createElevators( _amountOfElevator, _amountOfFloors)
            number_of_elevator = _amountOfElevator
            elevator_id = 1
            for elevator_id in 1..number_of_elevator
                elevator = Elevator.new(elevator_id, "idle", _amountOfFloors, 1)
                @elevator_list.push(elevator)
                elevator_id += 1
            end
        end
        #function that will call elevator to the floor your on
        def requestElevator( floor, direction)
            elevator = self.findElevator(floor, direction)
            elevator.pushToArray(floor)
            elevator.sortFloorList()
            elevator.move()
            elevator.operateDoors()
            return elevator
        end

        #send point to each elevator to find the best one   
        def findElevator( floor, direction)
            bestElevatorInformation = {
                "bestElevator" => nil,
                "bestScore" => 5,
                "referenceGap" => 10000000}
            

            for elevator in @elevator_list
                if floor == elevator.getPosition and elevator.getStatus == "idle"
                    bestElevatorInformation = self.checkIfElevatorIsBetter(1, elevator, bestElevatorInformation, floor)
                elsif floor > elevator.getPosition and elevator.getDirection == "up" and direction == elevator[direction]
                    bestElevatorInformation = self.checkIfElevatorIsBetter(2, elevator, bestElevatorInformation, floor)
                elsif floor < elevator.getPosition and elevator.getDirection == "down" and direction == elevator[direction]
                    bestElevatorInformation = self.checkIfElevatorIsBetter(2, elevator, bestElevatorInformation, floor)
                elsif elevator.getStatus == "idle"
                    bestElevatorInformation = self.checkIfElevatorIsBetter(3, elevator, bestElevatorInformation, floor)
                else
                    bestElevatorInformation = self.checkIfElevatorIsBetter(4, elevator, bestElevatorInformation, floor)
                end
            end
            return bestElevatorInformation["bestElevator"]
        end
        
        #use point to check witch elevator is better
        def checkIfElevatorIsBetter( scoreToCheck, newElevator, bestElevatorInformation, floor)
            if scoreToCheck < bestElevatorInformation["bestScore"]
                bestElevatorInformation['bestScore'] = scoreToCheck
                bestElevatorInformation["bestElevator"] = newElevator
                bestElevatorInformation["referenceGap"] = (newElevator.getPosition - floor).abs

            elsif bestElevatorInformation["bestScore"] == scoreToCheck
                gap = (newElevator.getPosition - floor).abs
                if bestElevatorInformation["referenceGap"] > gap
                    bestElevatorInformation["bestElevator"] = newElevator
                    bestElevatorInformation["referenceGap"] = gap
                end
            end
                
            return bestElevatorInformation
        end
    
        def checkRequestList()  #only use for senario 3 
            for elevator in @elevator_list
                if elevator.getFloor_request_list != []
                    elevator.sortFloorList()
                    elevator.move()
                    elevator.operateDoors()
                end
            end
        end
    end

    class CallButton
        def initialize( _id, _status, _floor, _direction)
            @ID = _id
            @status = _status
            @floor = _floor
            @direction = _direction
        end
    end


    class Elevator
        def initialize( _id, _status, _amountOfFloors, _currentFloor)
            @ID = _id
            @status = _status
            @direction = "null"
            @amountOfFloors = _amountOfFloors
            @currentFloor = _currentFloor
            @door = Door.new(@door_id, "close")
            @floorRequestButtonsList = []
            @floorRequestList = []

            self.createFloorRequestButton(_amountOfFloors)
        end

        def setPosition(value)
            @currentFloor = value
        end

        def setDirection(value)
            @direction = value
        end

        def setStatus(value)
            @status = value
        end

        def pushToArray(value)
            @floorRequestList.push(value)
        end

        def getFloor_request_list
            @floorRequestList
        end

        def getPosition
            @currentFloor
        
        end

        def getStatus
            @status
        end

        def getDirection
            @direction
        end

        def getId
            @ID
        end
        

        #making my button in each elevator made
        def createFloorRequestButton( _amountOfFloors)
            button_floor = 1
            for button_floor in 1.._amountOfFloors
                floorRequestButton = FloorRequestButton.new( button_floor, "off", button_floor)
                @floorRequestButtonsList.push(floorRequestButton)
                
                button_floor += 1
            end
        end
        #requesting a floor once inside elevator
        def requestFloor(floor)
            @floorRequestList.push(floor)
            self.sortFloorList()
            self.move()
            self.operateDoors()
        end
            
            
        #move the elevator in the right direction
        def move()
            while @floorRequestList != []
                destination = @floorRequestList[0]
                @status = "moving"
                puts("elevator  #{@ID}   is moving")
                if @currentFloor < destination
                    @direction = "up"
                    while @currentFloor < destination
                        @currentFloor += 1
                        puts("elevator #{@ID} moving to floor #{@currentFloor}")
                    end
                elsif @currentFloor > destination
                    @direction = "down"
                    while @currentFloor > destination
                        @currentFloor -= 1
                        puts("elevator #{@ID} moving to floor #{@currentFloor}")
                    end
                end
                @status = "idle"
                @direction = "null"
                puts("elevato #{@ID} is stopped" )
                @floorRequestList.shift()
            end
        end
        #sort my floor list
        def sortFloorList()
            if @direction == "up"
                @floorRequestList.sort!()
            else
                @floorRequestList.sort!()
                @floorRequestList.reverse!()
            end
        end
        #open door and close after 5 sec
        def operateDoors()
            @door.setStatus("open")
            puts("#{@door.getStatus} door")
            puts("please wait 2 seconds")
            @door.setStatus("close")
            puts("#{@door.getStatus} door")
        end
    end


    class Door
        def initialize( _id, _status)
            @ID = _id
            @status = _status
        end

        def setStatus(value)
            @status = value
        end
        def getStatus
            @status
        end

    end

    class FloorRequestButton
        def initialize( _id, _status, _floor)
            @ID = _id
            @status = _status
            @floor = _floor
        end
    end


    def senario1()
        column = Column.new(1, "online", 10, 2)
        elevators = column.getElevatorList
        elevators[0].setPosition(2)
        elevators[1].setPosition(6)
        scenario = column.requestElevator(3, "up")
        scenario.requestFloor(7)
    end
        
    def senario2()
        column = Column.new(1, "online", 10, 2)
        column.getElevatorList[0].setPosition(10)
        column.getElevatorList[1].setPosition(3)
        scenario = column.requestElevator(1, "up")
        scenario.requestFloor(6)
        scenario1 = column.requestElevator(3, "up")
        scenario1.requestFloor(5)
        scenario1 = column.requestElevator(9, "down")
        scenario1.requestFloor(2)
    end
    

    def senario3()
        column = Column.new(1, "online", 10, 2)
        column.getElevatorList[0].setPosition(10)
        column.getElevatorList[1].setPosition(3)
        column.getElevatorList[1].setStatus("moving")
        column.getElevatorList[1].pushToArray(6)
        scenario = column.requestElevator(3, "down")
        scenario.requestFloor(2)
        column.checkRequestList()
        scenario1 = column.requestElevator(10, "down")
        scenario1.requestFloor(3)
    end


end