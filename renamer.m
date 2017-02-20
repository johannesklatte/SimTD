clear;

data = load('driveStatsSimple.mat');

data = data.driveStats;

data.Properties.VariableNames = {'Timestamp' 'Engine_speed' 'Vehicle_speed' 'Latitude_GPS' 'Longitude_GPS'                              ...    %01-05
    'Heading_GPS' 'Altitude_GPS' 'Vehicle_speed_GPS' 'Long_acceleration' 'Lat_acceleration' 'Steeringwheel_angle'...   %06-11
    'Object_detected' 'Relative_speed_to_object' 'Distance_to_object' 'Pedal_force' 'Turn_signal_front_left' ...       %12-16
    'Turn_signal_front_right' 'Turn_signal_rear_left' 'Turn_signal_rear_right' 'clutch'  'Gear_selection'       ...    %17-21
    'Current_gear' 'Steeringwheel_velocity' 'Odometer' 'Trip_odometer' 'Brake_actuation'  'cruise_control'  'ABS'  ... %22-28
    'Exterior_temperature' 'Hazard_ligths' 'Daytime_running_lights' 'Front_light_low_beam' 'Front_light_high_beam'  ...%29-33
    'Fog_light' 'Emergency_Light' 'Wiper_front' 'Wiper_rear'                                                        ...%34-37
     };


driveStats = data;

save('driveStatsSimple.mat', 'driveStats');