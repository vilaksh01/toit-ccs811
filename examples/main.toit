import quiic_ccs811 as CCS811

import i2c
import gpio

main:
  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22

  device := bus.device CCS811.I2C_ADDRESS_ALT

  sensor := CCS811.QuiicCCS811 device
  sensor.on
  while true:
    sensor.read_algorithm_result
    sleep --ms=5000
    print "CO2:  $sensor.get_co2"
    sleep --ms=5000
    print "TVOC: $sensor.get_tvoc"
    sleep --ms=5000
    
    

