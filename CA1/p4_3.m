function p4_3(x, speed)
    valid_speeds = 0.5 : 0.1 : 2.0;
    
    if ismember(speed, valid_speeds) == false
    error('it is not a valid speed!');
    end
    
    [audio_data, fs] = audioread(x);
    sound(audio_data, fs * speed);
end