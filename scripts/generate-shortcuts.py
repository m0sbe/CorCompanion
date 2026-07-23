#!/usr/bin/env python3
"""Build the bundled catalogue from the reviewed official Corel quick cards."""

import json
import uuid
from pathlib import Path

# category | Russian title | English title | Windows | macOS
# Empty platform values mean that the official card does not assign a shortcut.
ROWS = r"""
file|Создать документ|New|Ctrl+N|Cmd+N
file|Открыть|Open|Ctrl+O|Cmd+O
file|Сохранить|Save|Ctrl+S|Cmd+S
file|Сохранить как|Save As|Ctrl+Shift+S|Cmd+Shift+S
file|Импорт|Import|Ctrl+I|Cmd+I
file|Экспорт|Export|Ctrl+E|Cmd+E
file|Печать|Print|Ctrl+P|Cmd+P
file|Выход|Exit|Alt+F4|
edit|Отменить|Undo|Ctrl+Z|Cmd+Z
edit|Повторить отменённое|Redo|Ctrl+Shift+Z|Cmd+Shift+Z
edit|Повторить команду|Repeat|Ctrl+R|Cmd+R
edit|Вырезать|Cut|Ctrl+X|Cmd+X
edit|Копировать|Copy|Ctrl+C|Cmd+C
edit|Вставить|Paste|Ctrl+V|Cmd+V
edit|Удалить|Delete|Delete|Delete
edit|Дублировать|Duplicate|Ctrl+D|Cmd+D
edit|Шаг и повтор|Step and Repeat|Ctrl+Shift+D|Ctrl+D
edit|Найти объекты|Find Objects|Ctrl+F|Ctrl+F
view|Полноэкранный просмотр|Full Screen Preview|F9|Ctrl+Cmd+P
view|Представления|Views|Ctrl+F2|Ctrl+V
view|Направляющие выравнивания|Alignment Guides|Alt+Shift+A|Cmd+Shift+A
view|Динамические направляющие|Dynamic Guides|Alt+Shift+D|Cmd+Shift+D
view|Привязка к сетке документа|Snap to Document Grid|Alt+Y|Cmd+Shift+Y
view|Привязка к объектам|Snap to Objects|Alt+Z|
view|Отключить привязки|Snap Off|Alt+Q|
view|Увеличить масштаб|Zoom In|Ctrl++|Option++
view|Уменьшить масштаб|Zoom Out|Ctrl+-|Option+-
arrange|Выровнять по левому краю|Align Left|L|Shift+L
arrange|Выровнять по правому краю|Align Right|R|Shift+R
arrange|Выровнять по верхнему краю|Align Top|T|Shift+T
arrange|Выровнять по нижнему краю|Align Bottom|B|Shift+B
arrange|Центры по горизонтали|Align Centers Horizontally|C|Shift+C
arrange|Центры по вертикали|Align Centers Vertically|E|Shift+E
arrange|По центру страницы|Center to Page|P|Shift+P
arrange|Выравнивание и распределение|Align and Distribute|Ctrl+Shift+A|Ctrl+A
object|На передний план страницы|To Front of Page|Ctrl+Home|Ctrl+Option+Cmd+]
object|На задний план страницы|To Back of Page|Ctrl+End|Ctrl+Option+Cmd+[
object|На передний план слоя|To Front of Layer|Shift+PageUp|Option+Cmd+]
object|На задний план слоя|To Back of Layer|Shift+PageDown|Option+Cmd+[
object|На один уровень вперёд|Forward One|Ctrl+PageUp|Cmd+]
object|На один уровень назад|Back One|Ctrl+PageDown|Cmd+[
object|Объединить кривые|Combine|Ctrl+L|Cmd+L
object|Разъединить кривые|Break Apart|Ctrl+K|Cmd+K
object|Группировать объекты|Group Objects|Ctrl+G|Cmd+G
object|Разгруппировать объекты|Ungroup Objects|Ctrl+U|Cmd+U
object|Преобразовать в кривые|Convert to Curves|Ctrl+Q|Ctrl+Q
object|Преобразовать абрис в объект|Convert Outline to Object|Ctrl+Shift+Q|Ctrl+Shift+Q
object|Свойства объекта|Object Properties|Alt+Enter|Ctrl+Enter
object|Менеджер символов|Symbol Manager|Ctrl+F3|Ctrl+Shift+S
effects|Яркость, контрастность, интенсивность|Brightness/Contrast/Intensity|Ctrl+B|Cmd+B
effects|Цветовой баланс|Color Balance|Ctrl+Shift+B|Cmd+Shift+B
effects|Оттенок, насыщенность, светлота|Hue/Saturation/Lightness|Ctrl+Shift+U|Cmd+Shift+U
effects|Контур|Contour|Ctrl+F9|Ctrl+Shift+C
effects|Оболочка|Envelope|Ctrl+F7|Ctrl+Shift+E
effects|Линза|Lens|Alt+F3|Ctrl+Shift+L
text|Свойства текста|Text Properties|Ctrl+T|Ctrl+Shift+T
text|Редактировать текст|Edit Text|Ctrl+Shift+T|
text|Вставить код форматирования|Insert Formatting Code|Ctrl+F8|
text|Неразрывный дефис|Non-breaking Hyphen|Ctrl+Shift+-|Cmd+Shift+-
text|Преобразовать текст|Convert Text|Ctrl+F8|Option+Cmd+Shift+T
text|Выровнять по базовой линии|Align to Baseline|Alt+F12|Option+Cmd+Shift+B
text|Проверка орфографии|Spell Check|Ctrl+F12|Option+Cmd+Shift+S
text|Вставить символ|Insert Character|Ctrl+F11|
text|Глифы|Glyphs|Ctrl+F11|Ctrl+G
window|Обновить окно|Refresh Window|Ctrl+W|
window|Закрыть окно|Close Window|Ctrl+F4|Cmd+Shift+W
window|Свойства|Properties Inspector|Alt+Enter|Ctrl+Enter
window|Стили объектов|Object Styles Inspector|Ctrl+F5|Ctrl+S
window|Символы|Symbols Inspector|Ctrl+F3|Ctrl+Shift+S
window|Шаг и повтор|Step and Repeat Inspector|Ctrl+Shift+D|Ctrl+D
window|Стили цвета|Color Styles Inspector||Ctrl+C
window|Сценарии|Scripts|Alt+Shift+F11|
window|Менеджер видов|View Manager|Ctrl+F2|
tools|Параметры|Options|Ctrl+J|
tools|Выбор|Pick Tool||V
tools|Форма|Shape Tool|F10|A
tools|Свободная форма|Freehand Tool|F5|N
tools|Перо|Pen Tool||Shift+N
tools|Художественное оформление|Artistic Media Tool|I|I
tools|LiveSketch|LiveSketch Tool||S
tools|Интеллектуальное рисование|Smart Drawing Tool|Shift+S|Shift+S
tools|Текст|Text Tool|F8|T
tools|Прямоугольник|Rectangle Tool|F6|R
tools|Эллипс|Ellipse Tool|F7|E
tools|Многоугольник|Polygon Tool|Y|Y
tools|Спираль|Spiral Tool|A|
tools|Разлинованная бумага|Graph Paper Tool|D|D
tools|Ластик|Eraser Tool|X|X
tools|Интерактивная заливка|Interactive Fill Tool|G|G
tools|Сетчатая заливка|Mesh Fill Tool|M|M
tools|Масштаб|Zoom Tool|Z|Z
tools|Панорамирование|Pan Tool|H|H
window|Сдвиг объекта|Nudge|ArrowUp|ArrowUp
window|Усиленный сдвиг|Super Nudge|Shift+ArrowUp|Shift+ArrowUp
window|Микросдвиг|Micro Nudge|Ctrl+ArrowUp|Cmd+ArrowUp
window|Прокрутка|Scroll|Alt+ArrowUp|Option+ArrowUp
"""

MODIFIERS = {"Ctrl": "control", "Cmd": "command", "Option": "option", "Alt": "option", "Shift": "shift"}
SPECIAL = {
    "Space": "space", "Tab": "tab", "Enter": "enter", "Delete": "delete", "Esc": "escape",
    "Home": "home", "End": "end", "PageUp": "pageUp", "PageDown": "pageDown",
    "ArrowUp": "arrowUp", "ArrowDown": "arrowDown", "ArrowLeft": "arrowLeft", "ArrowRight": "arrowRight",
}

def shortcut(value):
    if not value:
        return None
    if value.endswith("++"):
        parts = value[:-2].split("+") + ["+"]
    else:
        parts = value.split("+")
    modifiers = [MODIFIERS[p] for p in parts[:-1]]
    key = parts[-1]
    if key.startswith("F") and key[1:].isdigit():
        key_value = {"type": "function", "value": int(key[1:])}
    elif key in SPECIAL:
        key_value = {"type": SPECIAL[key]}
    else:
        key_value = {"type": "character", "value": key.upper()}
    return {"modifiers": modifiers, "key": key_value}

entries = []
for line in ROWS.strip().splitlines():
    category, ru, en, windows, mac = line.split("|")
    entries.append({
        "id": str(uuid.uuid5(uuid.NAMESPACE_URL, f"corel-companion:{en}" )).upper(),
        "category": category,
        "titleRU": ru,
        "titleEN": en,
        "windowsShortcut": shortcut(windows),
        "macShortcut": shortcut(mac),
        "notes": "CorelDRAW Quick Reference Card 2020; verify customized assignments in CorelDRAW 2026."
    })

target = Path(__file__).resolve().parents[1] / "CorelCompanion/Resources/shortcuts.json"
target.write_text(json.dumps(entries, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"Wrote {len(entries)} entries to {target}")
