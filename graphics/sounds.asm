song_index_4eew20song = 0

song_list:
  .dw _4eew20song

instrument_list:
  .dw New_instrument_0
  .dw silent_1

New_instrument_0:
  .db 5,22,24,26,ARP_TYPE_ABSOLUTE
  .db 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

silent_1:
  .db 5,7,9,11,ARP_TYPE_ABSOLUTE
  .db 0,ENV_STOP
  .db 0,ENV_STOP
  .db 0,DUTY_ENV_STOP
  .db ENV_STOP

_4eew20song:
  .db 0
  .db 6
  .db 0
  .db 5
  .dw _4eew20song_square1
  .dw 0
  .dw 0
  .dw _4eew20song_noise
  .dw 0

_4eew20song_square1:
_4eew20song_square1_loop:
  .db CAL,low(_4eew20song_square1_0),high(_4eew20song_square1_0)
  .db GOT
  .dw _4eew20song_square1_loop

_4eew20song_noise:
_4eew20song_noise_loop:
  .db CAL,low(_4eew20song_noise_0),high(_4eew20song_noise_0)
  .db GOT
  .dw _4eew20song_noise_loop

_4eew20song_square1_0:
  .db STI,0,SL4,C3,E3,G3,E3,C3,E3,G3,E3,A2,C3,G3,C3,B2,E3,G3,E3
  .db RET

_4eew20song_noise_0:
  .db STI,0,SL4,13,SL2,14,14,14,14,SL4,11,12,SL2,12,11,SL4,12,12
  .db 12,SL2,12,12,12,12,12,11,SL4,12,11,11,11
  .db RET

