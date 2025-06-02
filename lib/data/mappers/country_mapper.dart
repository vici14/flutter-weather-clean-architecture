import '../../domain/entities/country_entity.dart';
import '../models/country.dart';

class CountryMapper {
  static CountryEntity toEntity(Country model) {
    return CountryEntity(
      id: model.id,
      name: model.name,
      iso2: model.iso2,
      iso3: model.iso3,
      phonecode: model.phonecode,
      capital: model.capital,
      currency: model.currency,
      native: model.native,
      emoji: model.emoji,
      numericCode: model.numeric_code,
      currencyName: model.currency_name,
      currencySymbol: model.currency_symbol,
      tld: model.tld,
      region: model.region,
      regionId: model.region_id,
      subregion: model.subregion,
      subregionId: model.subregion_id,
      nationality: model.nationality,
      timezones: model.timezones,
      translations: model.translations,
      latitude: model.latitude,
      longitude: model.longitude,
      emojiU: model.emojiU,
    );
  }

  static Country toModel(CountryEntity entity) {
    return Country(
      id: entity.id,
      name: entity.name,
      iso2: entity.iso2,
      iso3: entity.iso3,
      phonecode: entity.phonecode,
      capital: entity.capital,
      currency: entity.currency,
      native: entity.native,
      emoji: entity.emoji,
      numeric_code: entity.numericCode,
      currency_name: entity.currencyName,
      currency_symbol: entity.currencySymbol,
      tld: entity.tld,
      region: entity.region,
      region_id: entity.regionId,
      subregion: entity.subregion,
      subregion_id: entity.subregionId,
      nationality: entity.nationality,
      timezones: entity.timezones,
      translations: entity.translations,
      latitude: entity.latitude,
      longitude: entity.longitude,
      emojiU: entity.emojiU,
    );
  }

  static List<CountryEntity> toEntityList(List<Country> models) {
    return models.map(toEntity).toList();
  }

  static List<Country> toModelList(List<CountryEntity> entities) {
    return entities.map(toModel).toList();
  }
}
