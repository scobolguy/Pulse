# Pulse  Reactive Event Language for ESPVM

Pulse is a purpose-built mid-level language for the [ESP Virtual P-Machine (ESPVM)](https://github.com/scobolguy/Reactive). It sits between raw MPAL assembly and full OO Pascal, designed specifically for IoT, home automation, and distributed sensor networks.

**Events are first-class.** Every Pulse program is a collection of event handlers  things that happen when a message arrives, when an HTTP request comes in, when a timer fires, or when a GPIO pin changes. The programmer declares *what* events to react to and *what* to do; the compiler handles all the context management, subscription wiring, and HTTP server setup.

## Quick Example

```pulse
module temperature_monitor

config
  sensor_pin: int = 36
  read_interval: int = 5000
  broker_topic: string = "sensors/temperature"
end

var last_temp: real = 0.0

on startup
  gpio.mode(config.sensor_pin, INPUT)
  logging.info("Temperature monitor started")
end

every config.read_interval
  var raw: int = gpio.analog_read(config.sensor_pin)
  last_temp = (real(raw) * 3300.0 / 4095.0 - 500.0) / 10.0
  publish config.broker_topic
    payload { celsius: last_temp, timestamp: time.now() }
    qos 1
  end
end

on http GET "/api/temperature" => get_temp

proc get_temp(req: request, res: response)
  respond res status 200 json { celsius: last_temp } end
end
```

## Features

- **Event Handlers**  `on startup`, `on shutdown`, `every N`, `on message`, `on http`, `on gpio`, `on idle`
- - **Async I/O**  `publish`, `enqueue`/`dequeue`, `await http.get()`
  - - **HTTP Server**  Declarative `serve`/`route`/`respond`
    - - **Parallel Execution**  `parallel`/`spawn` with `on node`/`on group` placement
      - - **Error Handling**  `try`/`catch`/`always`/`throw`
        - - **Typed but Terse**  `int`, `real`, `string`, `bool`, `complex`, `json`, `record`, `enum`, `array` with type inference
          - - **Config as Data**  Declarative `config` blocks with typed defaults
            - - **No OO Baggage**  Records + procedures. If you need classes, use Pascal.
             
              - ## Architecture
             
              - Pulse compiles to the same pcode as Pascal and COBOLish and runs on both the JS VM and the C++ ESP32 VM.
             
              - ```
                source.pulse  ANTLR Lexer/Parser  AST  Semantic Analysis  Code Generation  .pmod
                ```

                The compiler is a Node.js ANTLR-based tool. The grammar (`Pulse.g4`) targets ANTLR4 with JavaScript runtime.

                ## Project Structure

                ```
                pulse/
                 grammar/
                    Pulse.g4              # ANTLR4 combined grammar
                 examples/
                    blink.pulse            # Minimal: GPIO blink with timer
                    temperature_monitor.pulse  # Sensor + MQTT + HTTP API
                    smart_thermostat.pulse     # Full-featured: control loop + parallel + error handling
                    api_gateway.pulse      # HTTP routing + service invocation
                 docs/
                    language-reference.md  # Quick reference card
                 test/
                    parse-test.js          # Grammar validation test harness
                 package.json
                 .gitignore
                 README.md
                ```

                ## Getting Started

                ### Prerequisites

                - Node.js 18+
                - - Java Runtime (for ANTLR4 tool)
                 
                  - ### Install
                 
                  - ```bash
                    npm install
                    ```

                    ### Generate Parser

                    ```bash
                    npm run generate
                    ```

                    This runs ANTLR4 on `grammar/Pulse.g4` and produces the parser in `src/generated/`.

                    ### Parse a Pulse File

                    ```bash
                    npm run parse -- examples/blink.pulse
                    ```

                    ### Run Tests

                    ```bash
                    npm test
                    ```

                    ## Design Principles

                    1. **Events are first-class**  No `main()`. Setup, then react.
                    2. 2. **Async without callbacks**  Linear code that suspends/resumes. No promises, no `async/await` keywords.
                       3. 3. **Typed but terse**  Type inference reduces boilerplate.
                          4. 4. **No classes, no inheritance**  Records + procedures. Sufficient for embedded.
                             5. 5. **Config as data, not code**  Declarative, schema-validatable.
                                6. 6. **Placement-aware**  `on node` / `on group` for distributed execution.
                                   7. 7. **One file, one module**  Simple mental model.
                                     
                                      8. ## Relationship to ESPVM
                                     
                                      9. Pulse is one of three languages targeting the ESPVM:
                                     
                                      10. | | Pulse | Pascal | COBOLish |
                                      11. |---|---|---|---|
                                      12. | **Use Case** | Reactive IoT / events | Structured programming | Business data processing |
                                      13. | **Event Handlers** | First-class | Manual daemon registration | PERFORM-based |
                                      14. | **Async I/O** | Built-in | SYS calls | Queue statements |
                                      15. | **OO Support** | No | Yes | No |
                                      16. | **Parser** | ANTLR | ANTLR (migrating from PEG.js) | ANTLR |
                                     
                                      17. ## Language Reference
                                     
                                      18. See [docs/language-reference.md](docs/language-reference.md) for the complete quick reference.
                                     
                                      19. Full specification: [ESPVM Architecture Document, Section 23](https://github.com/scobolguy/Reactive).
                                     
                                      20. ## License
                                     
                                      21. MIT
                                      22. 
