song_index_4eew20song = 0

song_list:
  .dw _4eew20song

instrument_list:
  .dw New_instrument_0
  .dw silent_1

New_instrument_0:
  .db 5,21,23,25,ARP_TYPE_ABSOLUTE
  .db 14,13,12,11,10,9,8,7,6,5,4,3,2,1,0,ENV_STOP
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
  .db STI,0,SL4,C4,SL2,C4,D4,SL4,E4,C4,SL2,C4,C4,C4,E4,F4,G4,SLL,36
  .db C4
  .db RET

_4eew20song_noise_0:
  .db STI,0,SL4,14,14,14,14,14,14,14,SLL,36,14
  .db RET

