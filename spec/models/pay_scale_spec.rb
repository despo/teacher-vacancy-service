require 'rails_helper'
RSpec.describe PayScale, type: :model do
  context 'scopes' do
    describe '#default' do
      it 'orders by index' do
        create(:pay_scale, index: 23)
        last = create(:pay_scale, index: 30)
        first = create(:pay_scale, index: 1)
        create(:pay_scale, index: 27)

        expect(PayScale.all.first).to eq(first)
        expect(PayScale.all.last).to eq(last)
      end
    end

    describe '#current' do
      it 'also orders by index' do
        last = create(:pay_scale, index: 30)
        first = create(:pay_scale, index: 1)

        expect(PayScale.current.first).to eq(first)
        expect(PayScale.current.last).to eq(last)
      end

      it 'includes pay scales that are current' do
        current = create(:pay_scale, starts_at: Time.zone.today - 2.days, expires_at: Time.zone.today + 2.days)
        expect(PayScale.current).to include(current)
      end

      it 'doesn’t include pay scales that haven’t started' do
        not_started = create(:pay_scale, starts_at: Time.zone.today + 2.days)
        expect(PayScale.current).not_to include(not_started)
      end

      it 'doesn’t include pay scales that have expired' do
        expired = create(:pay_scale, expires_at: Time.zone.today - 2.days)
        expect(PayScale.current).not_to include(expired)
      end
    end
  end

  describe '#minimum_payscale_salary' do
    it 'returns the lowest current pay scale salary' do
      Timecop.freeze(Time.zone.today) do
        minimum = create(:pay_scale,
                         salary: 1000, starts_at: Time.zone.today - 2.days, expires_at: Time.zone.today + 2.days)
        create(:pay_scale, salary: 2000, starts_at: Time.zone.today - 2.days, expires_at: Time.zone.today + 2.days)
        future_minimum = create(:pay_scale, salary: 5000, starts_at: Time.zone.today + 2.months)
        create(:pay_scale, salary: 6000, starts_at: Time.zone.today + 2.months)

        expect(PayScale.minimum_payscale_salary).to be minimum.salary

        Timecop.travel(Time.zone.today + 3.months)
        expect(PayScale.minimum_payscale_salary).to be future_minimum.salary
      end
    end
  end
end
