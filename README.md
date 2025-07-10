# 🧪 TestRunnerApp

TestRunnerApp is a simple Windows desktop application that allows you to run automated tests (e.g., unit tests) using the Visual Studio test engine (`vstest.console.exe`). It displays real-time test output in a graphical user interface.

This app is built using clean, maintainable coding practices — but **you do not need to know any advanced architecture like MVVM or Clean Architecture** to use or work with it. This guide explains everything in plain terms.

---

## ✅ What Does This App Do?

- Lets you enter the path to a `.dll` file that contains your tests.
- Runs those tests using the built-in Visual Studio test runner.
- Shows test output and errors in real-time in a window.
- Keeps your user interface responsive while tests are running in the background.

---

## 🚀 How to Run It

1. **Open the solution** in Visual Studio.
2. Make sure your system has `.NET 6 SDK` installed.
3. Ensure `vstest.console.exe` is in your system PATH. (It comes with Visual Studio.)
4. Build the solution.
5. Run the `TestRunnerApp.UI` project.
6. Enter the path to your test `.dll` and click **Run Tests**.

---

## 🧱 How the App is Organized

To make the code easy to understand and maintain, we split the project into parts:

### 1. `UI` (User Interface)

This is the window you see. It has a button, a text box for entering the test DLL path, and a log window.

> You don’t need to touch this unless you want to change how the app looks.

### 2. `ViewModel`

This is the “middle-man” between the UI and the logic. It handles the click of the button and sends the test path to the test runner.

> Think of it like the controller in MVC or the glue between the UI and the logic.

### 3. `Services`

These are reusable tools that do the actual work — such as:

- Running `vstest.console.exe`
- Logging output to the screen (and potentially to a file later)

### 4. `Core`

This is where we define simple interfaces and data models. It's like the contract or blueprint of what the app should do.

> You don’t have to change these unless you’re adding new features.

---

## 🧪 How the Test Running Works

1. When you click **Run Tests**, the app starts a background task.
2. This task runs `vstest.console.exe` on the file you provided.
3. The app listens to the output and errors from that process.
4. It shows the output line-by-line in the log viewer.
5. The UI stays responsive — it doesn’t freeze.

---

## 🔧 How to Customize

You can:
- Change how logs look by editing the WPF view (`MainWindow.xaml`)
- Run tests from multiple assemblies by modifying the ViewModel
- Save output to a file by extending the logging service

---

## 🧪 Unit Testing Support

There is a test project (`TestRunnerApp.Tests`) where we verify that:
- The ViewModel correctly logs output when tests are run
- The UI doesn’t need to be tested directly — just the logic

---

## 📦 Technologies Used

- .NET 6
- WPF (Windows UI)
- Dependency Injection (for clean service management)
- MVVM Toolkit (simplifies commands and property bindings)
- xUnit + Moq (for testing)

---

## 📁 Folder Structure

```plaintext
TestRunnerApp/
├── Core/           # Interfaces and basic models
├── Infrastructure/ # Code that runs vstest.exe and logs messages
├── UI/             # The window and view model
├── Tests/          # Unit tests
```

---

## 🙋 What is MVVM?

If you’ve never heard of MVVM — no problem. Here's a quick explanation:

- **Model**: Your data — like test results or log lines.
- **View**: The window (what the user sees).
- **ViewModel**: The logic that reacts to clicks and runs the tests.

They are kept separate so:
- The code is easier to test and reuse.
- You don’t have to rewrite everything when the UI changes.

---

## 🙋 What is Clean Architecture?

Clean Architecture is just a fancy way of saying:

- Keep your **core logic** separate from things like UI or files.
- Write **interfaces** for things you might want to swap out later (like test runners, loggers, etc.)
- Makes it easier to **test**, **scale**, and **maintain**.

---

## ✨ Future Ideas

- Parse test results and display pass/fail stats
- Save logs to a file
- Run multiple test files in sequence
- Export to HTML or JSON

---

## 🛠️ Need Help?

If you’re stuck or want to expand this project, feel free to reach out or ask for feature-specific examples.

Happy testing!
