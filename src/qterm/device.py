from serial import Serial
from typing import Any


class SerialDevice(Serial):
    """Generic RS232 serial connection"""

    def __init__(
        self,
        port: str,
        baudrate: int = 115200,
        timeout: float | None = None,
        encoding: str = "utf-8",
        delimiter: str = "\n",
    ):
        super().__init__(port=port, baudrate=baudrate, timeout=timeout)

        self.encoding = encoding
        self.delimiter = delimiter

    def reset_buffers(self) -> None:
        """Reset rx and tx buffers"""
        self.reset_input_buffer()
        self.reset_output_buffer()

    def send(self, msg: str | Any) -> None:
        """Send bytearray to device"""
        if isinstance(msg, str):
            self.write(f"{msg}{self.delimiter}".encode(self.encoding))
        else:
            self.write(msg + self.delimiter.encode(self.encoding))

    def recv(self) -> str:
        """Receive bytearray from device"""
        return self.read_until(self.delimiter.encode(self.encoding)).decode(
            self.encoding
        )
