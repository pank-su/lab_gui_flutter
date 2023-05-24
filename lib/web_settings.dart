import "dart:html";

/// Настройки для web версии приложении:
/// - отключение нажатия правой кнопки мыши
void webSet(){
    window.document.onContextMenu.listen((evt) => evt.preventDefault());
  
}