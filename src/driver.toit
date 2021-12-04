// Copyright (C) 2021 Sumit Kumar. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import binary
import serial.device as serial
import serial.registers as serial
import math


/**
Quiic CCS811 Driver.
*/

DEFAULT_NAME ::= "Quiic CCS811 Environmental Sensor Driver"
I2C_ADDRESS ::= 0x5A
I2C_ADDRESS_ALT ::= 0x5B
CO2 := 0
TVOC := 0

class QuiicCCS811:
  // Address Map registers
  static STATUS_ ::= 0x00
  static MEAS_MODE_ ::= 0x01
  static ALG_RESULT_DATA_ ::= 0x02
  static RAW_DATA_ ::= 0x03
  static ENV_DATA_ ::= 0x05
  static NTC_ ::= 0x06
  static THRESHOLDS_ ::= 0x10
  static BASELINE_ ::= 0x11
  static HW_ID_ADDRESS_ ::= 0x20
  static HW_VERSION_ ::= 0x21
  static FW_BOOT_VERSION_ ::= 0x23
  static FW_APP_VERSION_ ::= 0x24
  static ERROR_ID_ ::= 0xE0
  static APP_START_ ::= 0xF4
  static SW_RESET_ ::= 0xFF
  static DEFAULT_ID ::= 0x81

  // Status register
  reg_/serial.Registers

  constructor device/serial.Device:
    reg_ = device.registers

  refResistance/float := 0.0
  SENSOR_SUCCESS          := 0
  SENSOR_ID_ERROR         := 1
  SENSOR_I2C_ERROR        := 2
  SENSOR_INTERNAL_ERROR   := 3
  SENSOR_GENERIC_ERROR    := 4
  temperature/float := 0.0
  humidity/float := 0.0

  
  on:
    reg := reg_.read_u8 HW_ID_ADDRESS_
    if reg != DEFAULT_ID : throw "Invalid Hardware ID"
    else:
      print "Device on successful. Hardware ID: $reg"

  read_algorithm_result:
    /**
    Reads the algorithm result data.
    returns: SENSOR_SUCCESS
    return type: integer
    */
    
    algodata := reg_.read_bytes ALG_RESULT_DATA_ 4
    CO2 = (algodata[0] << 8) | algodata[1]
    TVOC = (algodata[2] << 8) | algodata[3]
    return SENSOR_SUCCESS
    
  set_environmental_data relative_humidity/float temperature/float:
    /**
    Given a temp and temperature, write this data to the CSS811 for the better compensation.
    This function expects temperature and humididity in float format.
    param relativeHumidity: The relativity Humity for the sensor to use
    param temperature: The temperature for the sensor to use
    
    return: one of the SENSOR_ return codes
    returns: SENSOR_SUCCESS
    **/

    // check if the relative humidity is valid
    if relative_humidity < 0 or relative_humidity > 100:
      throw SENSOR_GENERIC_ERROR

    // check if the temperature is valid
    if temperature < -25 or temperature > 50:
      throw SENSOR_GENERIC_ERROR
    
    // convert the relative humidity to a uint16, like 42.348 becomes 42348
    rh/int := int.parse relative_humidity * 1000
    temp/int := int.parse temperature * 1000

    envData/ByteArray := #[0x00, 0x00, 0x00, 0x00]
    envData[0] = (rh + 250) / 500
    envData[1] = 0

    temp += 25000 
    envData[2] = (temp+250) / 500
    envData[3] = 0
    reg_.write_bytes ENV_DATA_ envData

    return SENSOR_SUCCESS

  get_co2:
    /**
    Gets the CO2 concentration in ppm.
    returns: the CO2 concentration in ppm
    **/
    return CO2

  get_tvoc:
    /**
    Gets the TVOC concentration in ppb.
    returns: the TVOC concentration in ppb
    **/
    return TVOC

  
  

  


