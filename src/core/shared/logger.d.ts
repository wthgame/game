export enum LogLevel {
	Trace = 0,
	Debug = 1,
	Info = 2,
	Warn = 3,
	Error = 4,
}

interface Pack extends Array<unknown> {
	n: number;
}

export interface LoggerMessage {
	when: number;
	logger: Logger;
	level: number;
	args: Pack;
}

export interface Logger {
	name: string;
	messages: LoggerMessage[];
	maxLevel?: number;

	trace(...args: unknown[]): LoggerMessage;
	debug(...args: unknown[]): LoggerMessage;
	info(...args: unknown[]): LoggerMessage;
	warn(...args: unknown[]): LoggerMessage;
	error(...args: unknown[]): LoggerMessage;

	assert<T>(value: T, ...args: unknown[]): asserts value;
	assert<T>(value: T, ...args: unknown[]): T extends Maybe<false> ? never : T;
}

export const LOG_LEVEL_TO_EMOJI: Record<keyof LogLevel, string>;
export function maxLevel(): LogLevel;
export function setDefaultMaxLevel(level: LogLevel): void;
export function setMaxLevelForThread(level?: LogLevel, thread?: thread): void;
export function formatMessage(message: LoggerMessage): string;

export function createLogger(name: string, maxLevel?: LogLevel): Logger;
