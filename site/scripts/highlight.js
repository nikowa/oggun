function setHighlightTheme() {
	const scheme = document.body.getAttribute("data-md-color-scheme");
	const isDark = scheme === "slate";

	const lightLink = document.querySelector('link[href*="intellij-light.css"]');
	const darkLink  = document.querySelector('link[href*="black-metal-bathory.css"]');

	if (!lightLink || !darkLink) return;

	lightLink.disabled = isDark;
	darkLink.disabled = !isDark; }

document.addEventListener("DOMContentLoaded", () => {
	setHighlightTheme();
	hljs.highlightAll(); });

const observer = new MutationObserver(setHighlightTheme);
observer.observe(document.body, {
	attributes: true,
	attributeFilter: ["data-md-color-scheme"] });