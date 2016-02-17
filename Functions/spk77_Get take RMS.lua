--[[
 * Version: 1.0
--]]

---------------------------------------------------
-- A function to get the average RMS from a take --
-- + an example (at the end)                     --
---------------------------------------------------

-- Function description/usage -- 
-- RMS_table = get_average_rms(MediaItem_Take, bool adj_for_take_vol, bool adj_for_item_vol, bool adj_for_take_pan, bool val_is_dB)
--  Returns a table (RMS values from each channel in an array)
    
function get_average_rms(take, adj_for_take_vol, adj_for_item_vol, adj_for_take_pan, val_is_dB)
  local RMS_t = {}
  if take == nil then
    return
  end
  
  local item = reaper.GetMediaItemTake_Item(take) -- Get parent item
  
  if item == nil then
    return
  end
  
  local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
  local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
  local item_end = item_pos+item_len
  local item_loop_source = reaper.GetMediaItemInfo_Value(item, "B_LOOPSRC") == 1.0 -- is "Loop source" ticked?
  
  -- Get media source of media item take
  local take_pcm_source = reaper.GetMediaItemTake_Source(take)
  if take_pcm_source == nil then
    return
  end
  
  -- Create take audio accessor
  local aa = reaper.CreateTakeAudioAccessor(take)
  if aa == nil then
    return
  end
  
  -- Get the length of the source media. If the media source is beat-based,
  -- the length will be in quarter notes, otherwise it will be in seconds.
  local take_source_len, length_is_QN = reaper.GetMediaSourceLength(take_pcm_source)
  if length_is_QN then
    return
  end

  local take_start_offset = reaper.GetMediaItemTakeInfo_Value(take, "D_STARTOFFS")
  
  
  -- (I'm not sure how this should be handled)
  
  -- Item source is looped --
  -- Get the start time of the audio that can be returned from this accessor
  local aa_start = reaper.GetAudioAccessorStartTime(aa)
  -- Get the end time of the audio that can be returned from this accessor
  local aa_end = reaper.GetAudioAccessorEndTime(aa)
   

  -- Item source is not looped --
  if not item_loop_source then
    if take_start_offset <= 0 then -- item start position <= source start position 
      aa_start = -take_start_offset
      aa_end = aa_start + take_source_len
    elseif take_start_offset > 0 then -- item start position > source start position 
      aa_start = 0
      aa_end = aa_start + take_source_len- take_start_offset
    end
    if aa_start + take_source_len > item_len then
      --msg(aa_start + take_source_len > item_len)
      aa_end = item_len
    end
  end
  --aa_len = aa_end-aa_start
  
  -- Get the number of channels in the source media.
  local take_source_num_channels = reaper.GetMediaSourceNumChannels(take_pcm_source)

  local channel_data = {} -- channel data is collected to this table
  -- Initialize channel_data table
  for i=1, take_source_num_channels do
    channel_data[i] = {
                        rms = 0,
                        sum_squares = 0 -- (for calculating RMS per channel)
                      }
  end
    
  -- Get the sample rate. MIDI source media will return zero.
  local take_source_sample_rate = reaper.GetMediaSourceSampleRate(take_pcm_source)
  if take_source_sample_rate == 0 then
    return
  end

  -- How many samples are taken from audio accessor and put in the buffer
  local samples_per_channel = take_source_sample_rate/10
  
  -- Samples are collected to this buffer
  local buffer = reaper.new_array(samples_per_channel * take_source_num_channels)
  
  --local take_playrate = reaper.GetMediaItemTakeInfo_Value(take, "D_PLAYRATE")
  
  -- total_samples = math.ceil((aa_end - aa_start) * take_source_sample_rate)
  local total_samples = math.floor((aa_end - aa_start) * take_source_sample_rate + 0.5)
  --total_samples = (aa_end - aa_start) * take_source_sample_rate
  
  -- take source is not within item -> return
  if total_samples < 1 then
    return
  end
  
  local block = 0
  local sample_count = 0
  local audio_end_reached = false
  local offs = aa_start
  
  local log10 = function(x) return math.log(x, 10) end
  local abs = math.abs
  --local floor = math.floor
  
  
  -- Loop through samples
  while sample_count < total_samples do
    if audio_end_reached then
      break
    end

    -- Get a block of samples from the audio accessor.
    -- Samples are extracted immediately pre-FX,
    -- and returned interleaved (first sample of first channel, 
    -- first sample of second channel...). Returns 0 if no audio, 1 if audio, -1 on error.
    local aa_ret = 
            reaper.GetAudioAccessorSamples(
                                            aa,                       -- AudioAccessor accessor
                                            take_source_sample_rate,  -- integer samplerate
                                            take_source_num_channels, -- integer numchannels
                                            offs,                     -- number starttime_sec
                                            samples_per_channel,      -- integer numsamplesperchannel
                                            buffer                    -- reaper.array samplebuffer
                                          )
      
    if aa_ret == 1 then
      for i=1, #buffer, take_source_num_channels do
        if sample_count == total_samples then
          audio_end_reached = true
          break
        end
        for j=1, take_source_num_channels do
          local buf_pos = i+j-1
          local spl = buffer[buf_pos]
          channel_data[j].sum_squares = channel_data[j].sum_squares + spl*spl
        end
        sample_count = sample_count + 1
      end
    elseif aa_ret == 0 then -- no audio in current buffer
      sample_count = sample_count + samples_per_channel
    else
      return
    end
    
    block = block + 1
    offs = offs + samples_per_channel / take_source_sample_rate -- new offset in take source (seconds)
  end -- end of while loop
  
  reaper.DestroyAudioAccessor(aa)
  
  
  -- Calculate corrections for take/item volume
  local adjust_vol = 1
  
  if adj_for_take_vol then
    adjust_vol = adjust_vol * reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
  end
  
  if adj_for_item_vol then
    adjust_vol = adjust_vol * reaper.GetMediaItemInfo_Value(item, "D_VOL")
  end
  
 
  local adjust_pan = 1
  
  -- Calculate RMS for each channel
  for i=1, take_source_num_channels do
    -- Adjust for take pan
    if adj_for_take_pan then
      local take_pan = reaper.GetMediaItemTakeInfo_Value(take, "D_PAN")
      if take_pan > 0 and i % 2 == 1 then
        adjust_pan = adjust_pan * (1 - take_pan)
      elseif take_pan < 0 and i % 2 == 0 then
        adjust_pan = adjust_pan * (1 + take_pan)
      end
    end
    
    local curr_ch = channel_data[i]
    curr_ch.rms = math.sqrt(curr_ch.sum_squares/total_samples) * adjust_vol * adjust_pan
    adjust_pan = 1
    RMS_t[i] = curr_ch.rms
    if val_is_dB then -- if function param "val_is_dB" is true -> convert values to dB
      RMS_t[i] = 20*log10(RMS_t[i])
    end
  end

  return RMS_t
end




-- EXAMPLE --
--  (Use ReaScript IDE to see the return values)

function msg(m)
  return reaper.ShowConsoleMsg(tostring(m) .. "\n")
end
