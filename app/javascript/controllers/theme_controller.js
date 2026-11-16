import { Controller } from "@hotwired/stimulus"

// Switches between the light and dark themes.
// The theme is a "dark" class on <html>; the choice is saved in localStorage
// so the inline script in the layout's <head> can restore it on the next visit.
export default class extends Controller {
  toggle() {
    const dark = !document.documentElement.classList.contains("dark")
    document.documentElement.classList.toggle("dark", dark)

    try {
      localStorage.setItem("theme", dark ? "dark" : "light")
    } catch {
      // Storage can be blocked (e.g. private browsing); the switch still works for this page
    }
  }
}
