CastClaim — это мини-приложение на Solidity для Farcaster, позволяющее связывать касты (посты) с дропами наград.
Создатель каста может запустить “reward drop” — пользователи, взаимодействовавшие с этим кастом (лайк, репост, ответ), могут клеймить токен через контракт.

Overview
Farcaster — это децентрализованная социальная сеть, где пользователи владеют своими данными.
CastClaim добавляет слой геймификации и социальных вознаграждений, соединяя офчейн-активность Farcaster с ончейн-наградами.

Основная идея:
Создатель публикует каст с тегом #claimdrop
Участники взаимодействуют с кастом
После подтверждения офчейн-сигнатуры (через Frame или API), они могут вызвать claimReward()
Контракт распределяет токены, а информация фиксируется ончейн

Установка и настройка
1. Клонирование репозитория
2. git clone https://github.com/Elmanilov/castclaim.git
cd castclaim

2. Установка зависимостей
3. npm install

Настройка .env
Создай файл .env в корне проекта и добавь:
PRIVATE_KEY=0xваш_приватный_ключ
RPC_URL=https://rpc-url-сети
ETHERSCAN_API_KEY=ключ_для_верификации_контракта
Никогда не коммить .env — в проекте он добавлен в .gitignore.

Деплой контракта
Скрипт деплоя находится в scripts/deploy.js.
npx hardhat run scripts/deploy.js --network sepolia

После деплоя будет выведен адрес контракта, например:
CastClaim deployed to: 0x1234abcd5678ef...

Взаимодействие с контрактом

Контракт находится в contracts/CastClaim.sol.

Основные функции
Функция	Описание
createDrop(uint256 amount)	Создаёт новый reward drop
signClaim(address user)	Подписывает право клейма для пользователя (off-chain, через backend)
claimReward(bytes signature)	Позволяет пользователю получить награду, если сигнатура валидна
withdrawUnclaimed()	Возврат неиспользованных токенов создателю дропа

Локальное тестирование
networks: {
  localhost: {
    url: "http://127.0.0.1:8545"
  },
  sepolia: {
    url: process.env.RPC_URL,
    accounts: [process.env.PRIVATE_KEY]
  }
}

Пример конфигурации сети для локального теста (в hardhat.config.js):
networks: {
  localhost: {
    url: "http://127.0.0.1:8545"
  },
  sepolia: {
    url: process.env.RPC_URL,
    accounts: [process.env.PRIVATE_KEY]
  }
}

Проверка контракта на Etherscan
После деплоя:
npx hardhat verify --network sepolia <адрес_контракта>
Изменения внесены с целью проверки подсчёта коммита
tested for base guild task
