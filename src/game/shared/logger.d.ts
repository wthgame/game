export enum LogLevel {
	Trace = 0,
	Debug = 1,
	Info = 2,
	Warn = 3,
	Error = 4,
}

export interface Log {
	when: number;
	logger: Logger;
	contents: any[];
	level: LogLevel;
}

export interface Logger {
	name: string;
	messages: Log[];

	trace: (...args: any[]) => void;
	debug: (...args: any[]) => void;
	info: (...args: any[]) => void;
	warn: (...args: any[]) => void;
	error: (...args: any[]) => void;
}

export const logs: Log[];
export function getDefaultLogLevel(): LogLevel;
export function setDefaultLogLevel(level: LogLevel): void;
export function createLogger(name: string, level?: LogLevel): Logger;
