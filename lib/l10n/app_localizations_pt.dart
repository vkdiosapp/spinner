// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Idiomas';

  @override
  String get continueButton => 'Continuar';

  @override
  String get save => 'Salvar';

  @override
  String get changeLanguage => 'Alterar Idioma';

  @override
  String get randomPicker => 'Giratório de Decisões';

  @override
  String get randomPickerDescription =>
      'Crie um spinner personalizado com seus próprios itens';

  @override
  String get multiplayer => 'Batalha de Giro';

  @override
  String get multiplayerDescription => 'Jogue com amigos e compita em rodadas';

  @override
  String get dice => 'Dados';

  @override
  String get diceDescription => 'Role dois dados e veja o total';

  @override
  String get whoFirst => 'Corrida para 10';

  @override
  String get whoFirstDescription => 'Jogue com amigos e compita em rodadas';

  @override
  String get adsOn => 'Anúncios Ligados';

  @override
  String get adsOff => 'Anúncios Desligados';

  @override
  String get vibrationOn => 'Vibração Ligada';

  @override
  String get vibrationOff => 'Vibração Desligada';

  @override
  String get soundOn => 'Som Ligado';

  @override
  String get soundOff => 'Som Desligado';

  @override
  String get spinnerTitle => 'Título do Spinner';

  @override
  String get enterSpinnerTitle => 'Digite o título do spinner';

  @override
  String get start => 'Iniciar';

  @override
  String get addItem => 'Adicionar Item';

  @override
  String get gameMode => 'Modo de Jogo';

  @override
  String get singlePlayer => 'Jogador Único';

  @override
  String get multiplayerMode => 'Multijogador';

  @override
  String get howManyRounds => 'Quantas Rodadas?';

  @override
  String get players => 'Jogadores';

  @override
  String get addPlayer => 'Adicionar Jogador';

  @override
  String get enterPlayerName => 'Digite o nome do jogador';

  @override
  String get truthDare => 'Verdade ou Desafio';

  @override
  String get close => 'Fechar';

  @override
  String get edit => 'Editar';

  @override
  String get reset => 'Redefinir';

  @override
  String get share => 'Compartilhar';

  @override
  String get truth => 'Verdade';

  @override
  String get dare => 'Desafio';

  @override
  String get earned => 'GANHO';

  @override
  String get selected => 'SELECIONADO';

  @override
  String get you => 'Você';

  @override
  String get computer => 'Computador';

  @override
  String get round => 'Rodada';

  @override
  String get leave => 'Sair';

  @override
  String get leaveGame => 'Sair do Jogo?';

  @override
  String get leaveGameMessage => 'Tem certeza de que deseja sair do jogo?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get gameResults => 'Resultados do Jogo';

  @override
  String get gold => 'Ouro';

  @override
  String get silver => 'Prata';

  @override
  String get bronze => 'Bronze';

  @override
  String get watchAd => 'Assistir Anúncio';

  @override
  String get toUnlock => 'para desbloquear';

  @override
  String get twoDice => 'Dois Dados';

  @override
  String get multiplication => 'Multiplicação';

  @override
  String get result => 'Resultado';

  @override
  String get spin => 'Girar';

  @override
  String get randomPickerTitle => 'Giratório de Decisões';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Nível';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Médio';

  @override
  String get hard => 'Difícil';

  @override
  String get selectLevel => 'Selecionar Nível';

  @override
  String get mathSpinner => 'Desafio Matemático';

  @override
  String get mathSpinnerDescription =>
      'Pratique matemática com desafios divertidos de spinner';

  @override
  String get spinnerItems => 'Itens do Spinner';

  @override
  String get enterItemName => 'Digite o nome do item';

  @override
  String get noItems =>
      'Nenhum item. Clique em \"Adicionar Item\" para adicionar itens.';

  @override
  String get pleaseAddAtLeastOneItem =>
      'Por favor, adicione pelo menos um item';

  @override
  String duplicateItemName(String item) {
    return 'Nome de item duplicado: \"$item\". Por favor, use nomes únicos.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Por favor, adicione pelo menos um usuário';

  @override
  String duplicateUserName(String user) {
    return 'Nome de usuário duplicado: \"$user\". Por favor, use nomes únicos.';
  }

  @override
  String get mathSpinnerComingSoon => 'Página Spinner de Matemática em breve!';

  @override
  String errorSharing(String error) {
    return 'Erro ao compartilhar: $error';
  }

  @override
  String get playerCount => 'Número de Jogadores';

  @override
  String get users => 'Usuários';

  @override
  String get enterUserName => 'Digite o nome de usuário';

  @override
  String total(String score) {
    return 'Total: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Rodadas: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      'Confira os resultados do nosso jogo de spinner multijogador!';

  @override
  String get allItemsUsed =>
      'Todos os itens de verdade ou desafio foram usados!';

  @override
  String errorLoadingData(String error) {
    return 'Erro ao carregar dados: $error';
  }

  @override
  String get dice1 => 'Dado 1';

  @override
  String get dice2 => 'Dado 2';

  @override
  String get resultUppercase => 'RESULTADO';

  @override
  String score(String score) {
    return 'Pontuação: $score';
  }

  @override
  String turn(String user) {
    return 'Turno de $user';
  }
}
