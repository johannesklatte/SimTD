patternDelimiter = ',';
                                    splittedString = strsplit(loopData{innerLoop,1}, patternDelimiter);

                                    % Keyword in the original data is at Position 3
                                    comparisonPosition = 3;
                                    comparisonElementTemp = splittedString{1, comparisonPosition};
                                    lengthComparisonElementTemp = length(comparisonElementTemp);
                                    comparisonElement = comparisonElementTemp(1, 21:lengthComparisonElementTemp);
                                    tempValue{1, 1} = 1;
                                    
                                    % 02 Rpm
                                    if(strcmp(comparisonElement, 'EngineSpeed'))
                                        % rpm position in fitered data = 2, value position = 5
                                        tempKey{1,1} = 2;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                    
                                    % 03 vehicle speed
                                    elseif(strcmp(comparisonElement, 'VehicleSpeed'))
                                        % vehicle speed position in fitered data = 3, value position = 5
                                        tempKey{1,1} = 3;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 12-17 GPS data  
                                    elseif(strcmp(comparisonElement, 'SimTD_FilteredPosition')) 
                                    % 12 latitude
                                    	%
                                        tempKey{1,1}  = 12;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                            
                                     	% 13 longitude
                                       	%
                                      	%filteredLoopData{(entryCounter), 13} = str2double(splittedString{1, 7});
                                      	tempKey{1,2}  = 13;
                                      	tempValue{1, 2} = str2double(splittedString{1, 7});

                                      	% 14 heading     
                                       	%                                                    
                                       	%filteredLoopData{(entryCounter), 14} = str2double(splittedString{1, 11});
                                      	tempKey{1,3}  = 14;
                                      	tempValue{1, 3} = str2double(splittedString{1, 11});

                                      	% 15 altitude
                                       	%                                                    
                                        %filteredLoopData{(entryCounter), 15} = str2double(splittedString{1, 13});
                                      	tempKey{1,4}  = 15;
                                     	tempValue{1, 4} = str2double(splittedString{1, 13});

                                      	% 16 vehicle speed  
                                      	%
                                      	%filteredLoopData{(entryCounter), 16} = str2double(splittedString{1, 21});
                                      	tempKey{1,5} = 16;
                                       	tempValue{1, 5} = str2double(splittedString{1, 21});    
                                        
                                    % 04 long. acceleration 
                                    elseif(strcmp(comparisonElement, 'LongitudinalAcceleration'))
                                        % long. acceleraction position in fitered data = 4, value position = 5
                                        tempKey{1,1} = 4;
                                        tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                              
                                    % 05 lat. acceleration  
                                    elseif(strcmp(comparisonElement, 'LateralAcceleration'))    
                                        % lat. acceleraction position in fitered data = 5, value position = 5
                                        tempKey{1,1} = 5;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                       
                                    % 08 steeringwheel angle 
                                    elseif(strcmp(comparisonElement, 'SteeringWheelAngle'))    
                                        %
                                    	tempKey{1,1} = 8;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});    
                                   
                                    % 19-21 object detection
                                    elseif(strcmp(comparisonElement, 'SimTD_ObjectDetection')) 
                                        % 19 object detected  
                                     	%
                                     	tempKey{1,1} = 19;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});

                                       	% 20 relative speed 
                                     	%
                                      	tempKey{1,2} = 20;
                                       	tempValue{1, 2} = str2double(splittedString{1, 7});

                                       	% 21 distance to object
                                     	%
                                     	tempKey{1,3} = 21;
                                      	tempValue{1, 3} = str2double(splittedString{1, 9});
                                               
                                    % 18 pedal force
                                    elseif(strcmp(comparisonElement, 'PedalForce')) 
                                        %
                                      	tempKey{1,1} = 18;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                    
                                    % 31 turn signal front left active   
                                    elseif(strcmp(comparisonElement, 'TurnSignalLights_FrontLeft'))
                                        %
                                       	tempKey{1,1} = 31;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 32 turn signal front right active 
                                    elseif(strcmp(comparisonElement, 'TurnSignalLights_FrontRight'))
                                    	%
                                      	tempKey{1,1} = 32;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});   
                                        
                                    % 33 turn signal rear left active 
                                    elseif(strcmp(comparisonElement, 'TurnSignalLights_RearLeft'))
                                        %
                                       	tempKey{1,1} = 33;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 34 turn signal rear right active
                                    elseif(strcmp(comparisonElement, 'TurnSignalLights_RearRight'))
                                        %
                                       	tempKey{1,1} = 34;
                                     	tempValue{1, 1} = str2double(splittedString{1, 5});
                                         
                                    % 23 clutch active 
                                    elseif(strcmp(comparisonElement, 'ClutchSwitchActuation'))
                                        %
                                      	tempKey{1,1} = 23;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                    
                                    % 25 exterior temperature 
                                    elseif(strcmp(comparisonElement, 'ExteriorTemperature'))
                                        %
                                       	tempKey{1,1} = 25;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                       
                                    % 06 gear selection
                                    elseif(strcmp(comparisonElement, 'GearSelection'))    
                                        %
                                    	tempKey{1,1} = 6;
                                    	tempValue{1, 1} = splittedString{1, 5}; % string 
          
                                    % 07 current gear  
                                    elseif(strcmp(comparisonElement, 'CurrentGear'))                                         
                                        %
                                        tempKey{1,1} = 7;
                                     	tempValue{1, 1} = splittedString{1, 5}; % string      
                                    
                                    % 09 steeringwheel velocity 
                                    elseif(strcmp(comparisonElement, 'SteeringWheelAngularVelocity'))
                                        %
                                    	tempKey{1,1} = 9;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 10 odometer
                                    elseif(strcmp(comparisonElement, 'Odometer'))
                                        %
                                       	tempKey{1,1} = 10;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                        
                                    % 11 trip odometer
                                    elseif(strcmp(comparisonElement, 'TripOdometer')) 
                                        %
                                      	tempKey{1,1} = 11;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                            
                                    % 17 brake actuation 
                                    elseif(strcmp(comparisonElement, 'BrakeActuation')) 
                                        %
                                        tempKey{1,5} = 17;
                                    	tempValue{1, 5} = str2double(splittedString{1, 5});
                                        
                                    % 22 cruise control active
                                    elseif(strcmp(comparisonElement, 'CruiseControlSystemState'))
                                        %
                                      	tempKey{1,1} = 22;
                                      	tempValue{1, 1} = splittedString{1, 5};    % string
                                       
                                    % 24 ABS active
                                    elseif(strcmp(comparisonElement, 'AntiLockBrakeSystem'))
                                        % 
                                       	tempKey{1,1} = 24;
                                       	tempValue{1, 1} = splittedString{1, 5};    % string
                                        
                                    % 25 exterior temperature 
                                    elseif(strcmp(comparisonElement, 'ExteriorTemperature'))
                                        %
                                       	tempKey{1,1} = 25;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 26 hazard ligths active  
                                    elseif(strcmp(comparisonElement, 'HazardWarningSystem'))
                                        %
                                     	tempKey{1,1} = 26;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    %  27 daytime running lights active 
                                    elseif(strcmp(comparisonElement, 'FrontLights_DaytimeRunningLamp'))
                                        %
                                      	tempKey{1,1} = 27;
                                        tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 28 front light low beam active  
                                    elseif(strcmp(comparisonElement, 'FrontLights_LowBeam'))
                                        %
                                      	tempKey{1,1} = 28;
                                      	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 29 front light high beam active
                                    elseif(strcmp(comparisonElement, 'FrontLights_HighBeam'))
                                        %
                                      	tempKey{1,1} = 29;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 30 fog light active 
                                    elseif(strcmp(comparisonElement, 'FogLight'))
                                        %
                                      	tempKey{1,1} = 30;
                                    	tempValue{1, 1} = str2double(splittedString{1, 5});
                                        
                                    % 35 emergency light active 
                                    elseif(strcmp(comparisonElement, 'EmergencyLighting'))
                                        %
                                       	tempKey{1,1} = 35;
                                       	tempValue{1, 1} = str2double(splittedString{1, 5}); 
                                        
                                    % 36 wiper front active  
                                    elseif(strcmp(comparisonElement, 'WiperSystem_Front'))
                                        %
                                       	tempKey{1,1} = 36;
                                       	tempValue{1, 1} = splittedString{1, 5};    % string
                                        
                                    % 37 wiper rear active  
                                    elseif(strcmp(comparisonElement, 'WiperSystem_Rear'))
                                        %
                                      	tempKey{1,1} = 37;
                                      	tempValue{1, 1} = splittedString{1, 5};    % string    
                                        
                                    %
                                    else
                                        % no pattern matched for this timestamp -> no entry in filtered list
                                      	matchFound = 0;

                                    end % elseif-end