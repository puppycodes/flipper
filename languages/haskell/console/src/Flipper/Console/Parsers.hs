module Flipper.Console.Parsers where

import Control.Applicative

import Data.Word

import Flipper

import Flipper.Console.Action

import Flipper.GPIO
import Flipper.LED

import Text.Megaparsec
import Text.Megaparsec.Lexer
import Text.Megaparsec.String

-- | One or more whitespace characters.
spaces :: Parser ()
spaces = skipSome spaceChar

parseConsoleAction :: Parser ConsoleAction
parseConsoleAction = choice [ try parseFlash
                            , try parseInstall
                            , try parseLaunch
                            , try parseReset
                            , try parseSuspend
                            , try parseFormat
                            , ConsoleCall <$> parseCall
                            ]

parseFlash :: Parser ConsoleAction
parseFlash = Flash <$> (string' "flash" *> spaces *> parseEscString)

parseInstall :: Parser ConsoleAction
parseInstall = Install <$> (string' "install" *> spaces *> parseModuleID)
                       <*> parseEscString

parseLaunch :: Parser ConsoleAction
parseLaunch = Launch <$> (string' "launch" *> spaces *> parseEscString)

parseReset :: Parser ConsoleAction
parseReset = string' "reset" *> pure Reset

parseSuspend :: Parser ConsoleAction
parseSuspend = string' "suspend" *> pure Suspend

parseFormat :: Parser ConsoleAction
parseFormat = string' "format" *> pure Format

parseCall :: Parser Call
parseCall = choice [ ADCCall <$> try parseADCAction
                   , ButtonCall <$> try parseButtonAction
                   , DACCall <$> try parseDACAction
                   , FSCall <$> try parseFSAction
                   , GPIOCall <$> try parseGPIOAction
                   , I2CCall <$> try parseI2CAction
                   , LEDCall <$> try parseLEDAction
                   , PWMCall <$> try parsePWMAction
                   , RTCCall <$> try parseRTCAction
                   , SPICall <$> try parseSPIAction
                   , SWDCall <$> try parseSWDAction
                   , TempCall <$> try parseTempAction
                   , TimerCall <$> try parseTimerAction
                   , UART0Call <$> try parseUART0Action
                   , USARTCall <$> try parseUSARTAction
                   , USBCall <$> try parseUSBAction
                   , WDTCall <$> try parseWDTAction
                   ]

parseADCAction :: Parser ADCAction
parseADCAction = string' "adc" *> spaces *> choice [ try parseADCAction
                                                   ]

parseButtonAction :: Parser ButtonAction
parseButtonAction = string' "button" *> spaces *> choice [ try parseButtonConfigure
                                                         , try parseButtonRead
                                                         ]

parseDACAction :: Parser DACAction
parseDACAction = string' "dac" *> spaces *> choice [ try parseDACConfigure
                                                   ]

parseFSAction :: Parser FSAction
parseFSAction = string' "fs" *> spaces *> choice [ try parseFSConfigure
                                                 , try parseFSCreate
                                                 , try parseFSDelete
                                                 , try parseFSSize
                                                 , try parseFSOpen
                                                 , try parseFSPushString
                                                 , try parseFSPullString
                                                 , try parseFSClose
                                                 ]

parseGPIOAction :: Parser GPIOAction
parseGPIOAction = string' "gpio" *> spaces *> choice gpios
    where gpios = [ try parseGPIOConfigure
                  , try parseGPIODigitalDirection
                  , try parseGPIODigitalRead
                  , try parseGPIODigitalWrite
                  , try parseGPIOAnalogDirection
                  , try parseGPIOAnalogRead
                  , try parseGPIOAnalogWrite
                  ]

parseI2CAction :: Parser I2CAction
parseI2CAction = string' "i2c" *> spaces *> choice [ try parseI2CConfigure
                                                   ]

parseLEDAction :: Parser LEDAction
parseLEDAction = string' "led" *> spaces *> choice [ try parseLEDConfigure
                                                   , try parseLEDsetRGB
                                                   ]

parsePWMAction :: Parser PWMAction
parsePWMAction = string "pwm" *> spaces *> choice [ try parsePWMConfigure
                                                  ]

parseRTCAction :: Parser RTCAction
parseRTCAction = string "rtc" *> spaces *> choice [ try parseRTCConfigure
                                                  ]

parseSPIAction :: Parser SPIAction
parseSPIAction = string' "spi" *> spaces *> choice [ try parseSPIConfigure
                                                   , try parseSPIEnable
                                                   , try parseSPIDisable
                                                   , try parseSPIRead
                                                   , try parseSPIWriteFromString
                                                   ]

parseSWDAction :: Parser SWDAction
parseSWDAction = string' "swd" *> spaces *> choice [ try parseSWDConfigure
                                                   ]

parseTempAction :: Parser TempAction
parseTempAction = string' "temp" *> spaces *> choice [ try parseTempConfigure
                                                     ]

parseTimerAction :: Parser TimerAction
parseTimerAction = string' "timer" *> spaces *> choice [ try parseTimerConfigure
                                                     ]

parseUART0Action :: Parser UART0Action
parseUART0Action = string' "uart0" *> spaces *> choice uart0s
    where uart0s = [ try parseUART0Configure
                   , try parseUART0Enable
                   , try parseUART0Disable
                   , try parseUART0Read
                   , try parseUART0WriteFromString
                   ]

parseUSARTAction :: Parser USARTAction
parseUSARTAction = string' "usart" *> spaces *> choice usarts
    where usarts = [ try parseUSARTConfigure
                   , try parseUSARTEnable
                   , try parseUSARTDisable
                   , try parseUSARTRead
                   , try parseUSARTWriteFromString
                   ]

parseUSBAction :: Parser USBAction
parseUSBAction = string' "usb" *> spaces *> choice [ try parseUSBConfigure
                                                   ]

parseWDTAction :: Parser WDTAction
parseWDTAction = string' "wdt" *> spaces *> choice [ try parseWDTConfigure
                                                   ]

parseADCConfigure :: Parser ADCAction
parseADCConfigure = string' "configure" *> pure ADCConfigure

parseButtonConfigure :: Parser ButtonAction
parseButtonConfigure = string' "configure" *> pure ButtonConfigure

parseButtonRead :: Parser ButtonAction
parseButtonRead = string' "read" *> pure ButtonRead

parseDACConfigure :: Parser DACAction
parseDACConfigure = string' "configure" *> pure DACConfigure

parseFSConfigure :: Parser FSAction
parseFSConfigure = string' "configure" *> pure FSConfigure

parseFSCreate :: Parser FSAction
parseFSCreate = FSCreate <$> (string' "create" *> spaces *> parseEscString)

parseFSDelete :: Parser FSAction
parseFSDelete = FSDelete <$> (string' "remove" *> spaces *> parseEscString)

parseFSSize :: Parser FSAction
parseFSSize = FSSize <$> (string' "size" *> spaces *> parseEscString)

parseFSOpen :: Parser FSAction
parseFSOpen = FSOpen <$> (string' "open" *> spaces *> parseEscString)
                     <*> (spaces *> parseWord32)

parseFSPushString :: Parser FSAction
parseFSPushString = FSPushString <$> ( string' "push"
                                       *> spaces
                                       *> parseEscString
                                     )

parseFSPullString :: Parser FSAction
parseFSPullString = string' "pull" *> pure FSPullString

parseFSClose :: Parser FSAction
parseFSClose = string' "close" *> pure FSClose

parseGPIOConfigure :: Parser GPIOAction
parseGPIOConfigure = string' "configure" *> pure GPIOConfigure

parseGPIODigitalDirection :: Parser GPIOAction
parseGPIODigitalDirection = GPIODigitalDirection <$> ( string' "direction"
                                                       *> spaces
                                                       *> parseDigitalPin
                                                     )
                                                 <*> (spaces *> parseDirection)

parseGPIODigitalRead :: Parser GPIOAction
parseGPIODigitalRead = GPIODigitalRead <$> ( string' "read"
                                             *> spaces
                                             *> parseDigitalPin
                                           )

parseGPIODigitalWrite :: Parser GPIOAction
parseGPIODigitalWrite = GPIODigitalWrite <$> ( string' "write"
                                               *> spaces
                                               *> parseDigitalPin
                                             )
                                         <*> (spaces *> parseBool)

parseGPIOAnalogDirection :: Parser GPIOAction
parseGPIOAnalogDirection = GPIOAnalogDirection <$> ( string' "direction"
                                                     *> spaces
                                                     *> parseAnalogPin
                                                   )
                                               <*> (spaces *> parseDirection)

parseGPIOAnalogRead :: Parser GPIOAction
parseGPIOAnalogRead = GPIOAnalogRead <$> ( string' "read"
                                           *> spaces
                                           *> parseAnalogPin
                                         )

parseGPIOAnalogWrite :: Parser GPIOAction
parseGPIOAnalogWrite = GPIOAnalogWrite <$> ( string' "write"
                                             *> spaces
                                             *> parseAnalogPin
                                           )
                                       <*> (spaces *> parseWord16)

parseI2CConfigure :: Parser I2CAction
parseI2CConfigure = string' "configure" *> pure I2CConfigure

parseLEDConfigure :: Parser LEDAction
parseLEDConfigure = string' "configure" *> pure LEDConfigure

parseLEDsetRGB :: Parser LEDAction
parseLEDsetRGB = LEDSetRGB <$> (string' "set" *> spaces *> parseRGB)

parsePWMConfigure :: Parser PWMAction
parsePWMConfigure = string' "configure" *> pure PWMConfigure

parseRTCConfigure :: Parser RTCAction
parseRTCConfigure = string' "configure" *> pure RTCConfigure

parseSPIConfigure :: Parser SPIAction
parseSPIConfigure = string' "configure" *> pure SPIConfigure

parseSPIEnable :: Parser SPIAction
parseSPIEnable = string' "enable" *> pure SPIEnable

parseSPIDisable :: Parser SPIAction
parseSPIDisable = string' "disable" *> pure SPIDisable

parseSPIRead :: Parser SPIAction
parseSPIRead = string' "read" *> pure SPIRead

parseSPIWriteFromString :: Parser SPIAction
parseSPIWriteFromString = SPIWriteFromString <$> ( string' "write"
                                                   *> spaces
                                                   *> parseEscString
                                                 )

parseSPIWriteFromFile :: Parser SPIAction
parseSPIWriteFromFile = SPIWriteFromFile <$> ( string' "writefile"
                                               *> spaces
                                               *> parseEscString
                                             )

parseSWDConfigure :: Parser SWDAction
parseSWDConfigure = string' "configure" *> pure SWDConfigure

parseTempConfigure :: Parser TempAction
parseTempConfigure = string' "configure" *> pure TempConfigure

parseTimerConfigure :: Parser TimerAction
parseTimerConfigure = string' "configure" *> pure TimerConfigure

parseUART0Configure :: Parser UART0Action
parseUART0Configure = string' "configure" *> pure UART0Configure

parseUART0Enable :: Parser UART0Action
parseUART0Enable = string' "enable" *> pure UART0Enable

parseUART0Disable :: Parser UART0Action
parseUART0Disable = string' "disable" *> pure UART0Disable

parseUART0Read :: Parser UART0Action
parseUART0Read = string' "read" *> pure UART0Read

parseUART0WriteFromString :: Parser UART0Action
parseUART0WriteFromString = UART0WriteFromString <$> ( string' "write"
                                                     *> spaces
                                                     *> parseEscString
                                                   )

parseUART0WriteFromFile :: Parser UART0Action
parseUART0WriteFromFile = UART0WriteFromFile <$> ( string' "writefile"
                                                 *> spaces
                                                 *> parseEscString
                                                 )

parseUSARTConfigure :: Parser USARTAction
parseUSARTConfigure = string' "configure" *> pure USARTConfigure

parseUSARTEnable :: Parser USARTAction
parseUSARTEnable = string' "enable" *> pure USARTEnable

parseUSARTDisable :: Parser USARTAction
parseUSARTDisable = string' "disable" *> pure USARTDisable

parseUSARTRead :: Parser USARTAction
parseUSARTRead = string' "read" *> pure USARTRead

parseUSARTWriteFromString :: Parser USARTAction
parseUSARTWriteFromString = USARTWriteFromString <$> ( string' "write"
                                                     *> spaces
                                                     *> parseEscString
                                                   )

parseUSARTWriteFromFile :: Parser USARTAction
parseUSARTWriteFromFile = USARTWriteFromFile <$> ( string' "writefile"
                                                 *> spaces
                                                 *> parseEscString
                                                 )

parseUSBConfigure :: Parser USBAction
parseUSBConfigure = string' "configure" *> pure USBConfigure

parseWDTConfigure :: Parser WDTAction
parseWDTConfigure = string' "configure" *> pure WDTConfigure

parseDigitalPin :: Parser DigitalPin
parseDigitalPin = choice [ try (string' "10" *> pure IO10)
                         , try (string' "11" *> pure IO11)
                         , try (string' "12" *> pure IO12)
                         , try (string' "13" *> pure IO13)
                         , try (string' "14" *> pure IO14)
                         , try (string' "15" *> pure IO15)
                         , try (string' "16" *> pure IO16)
                         , try (string' "1" *> pure IO1)
                         , try (string' "2" *> pure IO2)
                         , try (string' "3" *> pure IO3)
                         , try (string' "4" *> pure IO4)
                         , try (string' "5" *> pure IO5)
                         , try (string' "6" *> pure IO6)
                         , try (string' "7" *> pure IO7)
                         , try (string' "8" *> pure IO8)
                         , try (string' "9" *> pure IO9)
                         ]

parseAnalogPin :: Parser AnalogPin
parseAnalogPin = choice [ try (string' "a1" *> pure A1)
                        , try (string' "a2" *> pure A2)
                        , try (string' "a3" *> pure A3)
                        , try (string' "a4" *> pure A4)
                        , try (string' "a5" *> pure A5)
                        , try (string' "a6" *> pure A6)
                        , try (string' "a7" *> pure A7)
                        , try (string' "a8" *> pure A8)
                        ]

parseDirection :: Parser Direction
parseDirection = choice [ try (string' "input" *> pure Input)
                        , try (string' "output" *> pure Output)
                        , try (string' "in" *> pure Input)
                        , try (string' "out" *> pure Output)
                        ]

parseRGB :: Parser RGB
parseRGB = RGB <$> parseWord8
               <*> (spaces *> parseWord8)
               <*> (spaces *> parseWord8)

parseModuleID :: Parser ModuleID
parseModuleID = ModuleID <$> sepBy1 (someTill alphaNumChar (string' "."))
                                    (string' ".")

parseEscString :: Parser String
parseEscString = string' "\"" *> esc
    where esc = do c <- anyChar
                   case c of '\\' -> anyChar >>= (\c' -> (c':) <$> esc)
                             '"'  -> pure []
                             _    -> (c:) <$> esc

parseBool :: Parser Bool
parseBool = choice [ try (string' "0" *> pure False)
                   , try (string' "false" *> pure False)
                   , try (string' "f" *> pure False)
                   , try (string' "1" *> pure True)
                   , try (string' "true" *> pure True)
                   , try (string' "t" *> pure True)
                   ]

parseAllocSize :: Parser Int
parseAllocSize = fromIntegral <$> parseIntegerLit

parseWord8 :: Parser Word8
parseWord8 = fromIntegral <$> parseIntegerLit

parseWord16 :: Parser Word16
parseWord16 = fromIntegral <$> parseIntegerLit

parseWord32 :: Parser Word32
parseWord32 = fromIntegral <$> parseIntegerLit

parseIntegerLit :: Parser Integer
parseIntegerLit = choice [ try integer
                         , try (string' "0x" *> hexadecimal)
                         ]

parseEndpoint :: Parser Endpoint
parseEndpoint = choice [ try parseUSBEndpoint
                       , try parseFVMEndpoint
                       , parseNetworkEndpoint
                       ]

parseUSBEndpoint :: Parser Endpoint
parseUSBEndpoint = string' "usb" *> option (USB Nothing)
                                    ((USB . Just) <$> ( string' ":"
                                                        *> some alphaNumChar)
                                                      )

parseNetworkEndpoint :: Parser Endpoint
parseNetworkEndpoint = Network <$> (some alphaNumChar)
                               <*> (some (alphaNumChar <|> char '.'))

parseFVMEndpoint :: Parser Endpoint
parseFVMEndpoint = string' "fvm" *> pure FVM
