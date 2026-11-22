# Pátio — controle de estacionamento

Aplicativo mobile em Flutter para registrar entradas e saídas de veículos, identificar mensalistas e aplicar descontos de comércios conveniados. O projeto inclui a atividade Android nativa em Kotlin.

## Funcionalidades

- Entrada por placa digitada ou fotografia com leitura de texto (OCR), com confirmação antes de salvar.
- Ticket próprio gerado a cada entrada.
- Busca de veículo pela placa e leitura da placa também no fluxo de saída.
- Cálculo de cobrança por hora iniciada, com 15 minutos de tolerância e tarifa configurável.
- Identificação de mensalista pela placa e saída sem cobrança enquanto o cadastro estiver válido.
- Cadastro e pausa de mensalistas e parceiros, com validade e regras de desconto percentual ou fixo.
- Registro e histórico de tickets de parceiros usados na saída.
- Persistência local no aparelho usando `shared_preferences`.

## Executar

```bash
flutter pub get
flutter run
```

O Android Studio deve ter um SDK Android instalado. Para usar a leitura por câmera, execute o app em um aparelho ou emulador com câmera disponível e aceite a permissão solicitada.

## Estrutura

- `lib/parking_home.dart`: telas e fluxos de operação.
- `lib/parking_controller.dart`: regras do estacionamento e persistência.
- `lib/parking_models.dart`: sessões, mensalistas e parceiros.
- `android/app/src/main/kotlin/.../MainActivity.kt`: atividade Android em Kotlin usada pelo Flutter.

Os dados ficam no dispositivo atual. A sincronização entre vários aparelhos e contas ainda depende de um backend, que não faz parte desta primeira versão.
