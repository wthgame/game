export function sans(weight: Enum.FontWeight = Enum.FontWeight.Regular, style: Enum.FontStyle = Enum.FontStyle.Normal) {
	return Font.fromName("Ubuntu", weight, style);
}

export function mono(weight: Enum.FontWeight = Enum.FontWeight.Regular, style: Enum.FontStyle = Enum.FontStyle.Normal) {
	return Font.fromName("Inconsolata", weight, style);
}
