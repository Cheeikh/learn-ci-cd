export function setupCounter(element: HTMLButtonElement) {
  let counter = 0
  const setCounter = (count: number) => {
    counter = count
    element.innerHTML = `count is ${counter}`
  }
  console.log('Ca marche')

  element.addEventListener('click', () => setCounter(counter + 1))
  setCounter(0)
}
