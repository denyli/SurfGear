# WidgetModel

[Главная](../main.md)
[Структура UI](structure.md)

Данная сущность представляет собой ViewModel из MVVM. 
В этой сущности описывается логика работы конкретного экрана.
Также можно провести аналогию с BLoC, но только в плане механизма взаимодейтсвия.

Работа с View(Widget) производится через поток. Данная модель ничего не знает про
конкретный виджет, который ее использует.

Основные компоненты WidgetModel - `Event'ы`:
 - Action - потоковое представление действия, ex: клик на кнопку, изменение фокуса.
 - StreamedState - потоковое представление того или иного свойства. ex: счетчик товаров, состояние enable
 - EntityStreamedState - наследник StreamedState, которое имеет состояния загрузки/ошибки/контента
 - дополнительная логика, которая связывает Действия и Стейт.

WM является промежуточным звеном между Model(в любом ее варианте) и Widget.

Зависимости из Model поставляются на WM также через конструктор.
В наших проектах для обепечения DI используется [Injector][].
Зависимости для WidgetModel конфигуриуются в компоненте экрана.
Для этого используется объект WidgetModelDependencies. Он содержит NavigatorState - объект, отвечающий
за роутинг в текущем контексте и ErrorHandler - объект, отвечающий за обработку ошибок для реактивных потоков.
Без конфигурации WidgetModelDependencies роутинг и обработка ошибок не будут работать в WidgetModel.