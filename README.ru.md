<div align="center">
  <a href="https://github.com/coonlink">
    <img src="https://raw.coonlink.com/cloud/AeroShake.png" alt="Aero Shake Logo" width="180"/>
  </a>
  <h1>Aero Shake for Linux</h1>

[![English](https://img.shields.io/badge/lang-English%20🇺🇸-white)](README.md)
[![Русский](https://img.shields.io/badge/язык-Русский%20🇷🇺-white)](README.ru.md)

<img alt="last-commit" src="https://img.shields.io/github/last-commit/crc137/Aero-Shake-for-Linux?style=flat&logo=git&logoColor=white&color=0080ff" style="margin: 0px 2px;">
<img alt="repo-top-language" src="https://img.shields.io/github/languages/top/crc137/Aero-Shake-for-Linux?style=flat&color=0080ff" style="margin: 0px 2px;">
<img alt="repo-language-count" src="https://img.shields.io/github/languages/count/crc137/Aero-Shake-for-Linux?style=flat&color=0080ff" style="margin: 0px 2px;">
<img alt="version" src="https://img.shields.io/badge/version-1.0.0-blue" style="margin: 0px 2px;">
<img src="https://img.shields.io/badge/made%20by-coonlink-blueviolet?style=flat-square" alt="coonlink" />

<sub><i>Классический Windows Aero Shake — теперь на Linux.</i></sub>

Порт классической функции Windows Aero Shake: хватаешь окно за заголовок, трясёшь его влево-вправо — и все остальные открытые окна сворачиваются. Активное окно остаётся на месте.

<p align="center">
  <img src="https://raw.coonlink.com/cloud/2026-07-01%2015-39-24.gif" alt="Aero Shake Demo" width="800"/>
</p>

</div>

## Возможности

- **Эмуляция Aero Shake** — тряска активного окна влево-вправо сворачивает все остальные окна на текущем рабочем столе
- **Иконка в трее** — Enable/Disable/Quit прямо из меню трея
- **Детекция по смене направления** — отслеживает реверсы движения в скользящем временном окне с cooldown'ом, чтобы избежать ложных срабатываний
- **Автозапуск** — устанавливает `.desktop`-файл в `~/.config/autostart/`
- **Фолбэк иконок** — иконки скачиваются при установке; если файлов нет во время работы, простые иконки генерируются на лету через Pillow
- **Подстройка анимаций GNOME** — установщик включает `enable-animations` через `gsettings`, чтобы анимация сворачивания выглядела плавно (вне GNOME просто молча пропускается)
- **Защита от дублей** — повторный запуск установщика при уже работающем приложении просто удаляет автозапуск, а не создаёт второй процесс

## Стек технологий

| Слой | Технологии |
|---|---|
| Логика приложения | Python 3, `subprocess`, `threading`, `time` |
| Интеграция с окружением | `xdotool`, `pystray`, Pillow, `python3-gi`, `gir1.2-ayatanaappindicator3-0.1` (или `gir1.2-appindicator3-0.1`), X11 (Xorg) |
| Установка | Bash, `curl`, `apt` |

## Требования

- X11 (Xorg) — Wayland **не поддерживается**, `xdotool` там нормально не работает
- Python 3
- Права sudo (установщику нужно ставить системные пакеты через `apt`)

## Установка

```bash
curl -sSL https://raw.coonlink.com/cloud/aero_shake.sh | bash
```

Или вручную:

```bash
sudo apt install -y xdotool
sudo mkdir -p /opt/aero_shake
sudo curl -sSL https://raw.coonlink.com/cloud/aero_shake.py -o /opt/aero_shake/aero_shake.py
sudo chmod +x /opt/aero_shake/aero_shake.py
python3 /opt/aero_shake/aero_shake.py
```

Установщик сам качает зависимости, разворачивает `/opt/aero_shake`, тянет иконки трея и регистрирует автозапуск — при следующих входах в систему ничего вручную делать не нужно.

## Использование

После установки скрипт работает в фоне, а рядом с регулятором громкости/микрофоном появляется иконка в трее. Клик по ней открывает Enable/Disable/Quit.

Пока функция включена: хватаешь любое окно за заголовок, трясёшь его влево-вправо несколько раз подряд — все остальные окна на текущем рабочем столе сворачиваются.

Запуск/остановка вручную:

```bash
python3 /opt/aero_shake/aero_shake.py   # запустить вручную
pkill -f aero_shake.py                  # остановить
```

## Как это работает

Фоновый поток опрашивает позицию активного окна (`xdotool getactivewindow` + `getwindowgeometry`) каждые 50 мс. На каждом опросе вычисляется смещение по доминирующей оси (той из dx/dy, что больше) с прошлого опроса. Если смещение превышает порог, фиксируется направление (влево-вправо или вверх-вниз); при каждой смене направления относительно предыдущего записывается метка времени "реверса". Как только за скользящее окно в 0.6 секунды набирается 4+ реверса, все окна текущего рабочего стола, кроме активного, сворачиваются через `xdotool windowminimize` (список окон берётся через `xdotool search --desktop <id>`). После срабатывания включается cooldown в 2 секунды, чтобы не сворачивать повторно. Иконка трея (`pystray`) работает в главном потоке и переключает enable/disable без завершения процесса; при отключении история реверсов очищается.

## Настройки

Все параметры захардкожены в `aero_shake.py`:

| Переменная | Что делает | По умолчанию |
|---|---|---|
| `MIN_STEP` | Порог смещения (px) для засчитывания направленного шага | 12 |
| `MIN_REVERSALS` | Количество реверсов направления для срабатывания | 4 |
| `WINDOW_SEC` | Скользящее окно для подсчёта реверсов (сек) | 0.6 |
| `cooldown_until = now + 2` | Cooldown после срабатывания (сек) | 2 |
| `time.sleep(0.05)` | Интервал опроса (сек) | 0.05 |
| `AERO_SHAKE_ICON_DIR` (переменная окружения) | Откуда грузятся PNG иконки трея | `/opt/aero_shake` |

## Известные ограничения

- Детекция построена на опросе, а не на событиях — под нагрузкой `xdotool getwindowgeometry` может лагать, из-за чего возможны ложные срабатывания и пропуски
- Реагирует на любые окна независимо от кнопки мыши, включая программные перемещения окон
- Тестировалось на XFCE; поведение `xdotool windowminimize` на GNOME/KDE может отличаться в зависимости от композитора
- Повторный запуск установщика при уже работающем приложении удаляет автозапуск вместо перезапуска — если нужен свежий процесс, скачай и запусти `aero_shake.py` вручную
- Что-то пошло не так? Нажми "Disable" в трее или выполни `pkill -f aero_shake.py`
- Иконке трея нужен трей с поддержкой AppIndicator — на лёгких WM без такого трея сворачивание всё равно работает, просто без переключателя в меню
- Чтобы отключить автозапуск: удали `~/.config/autostart/aero-shake.desktop`
