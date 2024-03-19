module AresMUSH
  module WOD20Skills
    describe WOD20Skills do

      before do
        allow(Global).to receive(:read_config).with("wod20skills", "free_languages") { 3 }
      end

      describe :points_on_attrs do
        before do
          @char = double
        end

        it "should count anything above average" do
          attrs = [ WOD20Attribute.new(rating: 5),
                    WOD20Attribute.new(rating: 2),
                    WOD20Attribute.new(rating: 3),
                    WOD20Attribute.new(rating: 4) ]
          allow(@char).to receive(:wod20_attributes) { attrs }
          expect(AbilityPointCounter.points_on_attrs(@char)).to eq 12
        end

        it "should not count average or below average" do
          attrs = [ WOD20Attribute.new(rating: 1),
                    WOD20Attribute.new(rating: 2),
                    WOD20Attribute.new(rating: 2),
                    WOD20Attribute.new(rating: 2) ]
          allow(@char).to receive(:wod20_attributes) { attrs }
          expect(AbilityPointCounter.points_on_attrs(@char)).to eq 0
        end
      end

      describe :points_on_action do
        before do
          @char = double
        end

        it "should count anything above everyman" do
          action = [ WOD20ActionSkill.new(rating: 2),
                     WOD20ActionSkill.new(rating: 3),
                     WOD20ActionSkill.new(rating: 4),
                     WOD20ActionSkill.new(rating: 5) ]
          allow(@char).to receive(:wod20_action_skills) { action }
          expect(AbilityPointCounter.points_on_action(@char)).to eq 10
        end

        it "should not count everyman or poor" do
          action = [ WOD20ActionSkill.new(rating: 1),
                     WOD20ActionSkill.new(rating: 1),
                     WOD20ActionSkill.new(rating: 1),
                     WOD20ActionSkill.new(rating: 0) ]
          allow(@char).to receive(:wod20_action_skills) { action }
          expect(AbilityPointCounter.points_on_action(@char)).to eq 0
        end
      end

      describe :points_on_background do
        before do
          @char = double
          allow(Global).to receive(:read_config).with("wod20skills", "free_backgrounds") { 5 }
        end

        it "should count past the free ones" do
          bg = [ WOD20BackgroundSkill.new(rating: 3),
                 WOD20BackgroundSkill.new(rating: 3),
                 WOD20BackgroundSkill.new(rating: 2) ]
          allow(@char).to receive(:wod20_background_skills) { bg }
          expect(AbilityPointCounter.points_on_background(@char)).to eq 3
        end

        it "should not count if below free ones" do
          bg = [ WOD20BackgroundSkill.new(rating: 2),
                 WOD20BackgroundSkill.new(rating: 1),
                 WOD20BackgroundSkill.new(rating: 1) ]
          allow(@char).to receive(:wod20_background_skills) { bg }
          expect(AbilityPointCounter.points_on_background(@char)).to eq 0
        end
      end

      describe :points_on_language do
        before do
          @char = double
          allow(Global).to receive(:read_config).with("wod20skills", "free_languages") { 4 }
        end

        it "should count past the free ones" do
          lang = [ WOD20Language.new(rating: 3),
                   WOD20Language.new(rating: 3),
                   WOD20Language.new(rating: 2) ]
          allow(@char).to receive(:wod20_languages) { lang }
          expect(AbilityPointCounter.points_on_language(@char)).to eq 4
        end

        it "should not count if below free ones" do
          lang = [ WOD20Language.new(rating: 2),
                   WOD20Language.new(rating: 1) ]
          allow(@char).to receive(:wod20_languages) { lang }
          expect(AbilityPointCounter.points_on_language(@char)).to eq 0
        end
      end

      describe :points_on_specialties do
        before do
          @char = double
        end

        it "should count abilities with more than one specialty" do
          action = [ WOD20ActionSkill.new(specialties: [ "A", "B" ]),
                     WOD20ActionSkill.new(specialties: ["C", "D", "E"] ) ]
          allow(@char).to receive(:wod20_action_skills) { action }
          expect(AbilityPointCounter.points_on_specialties(@char)).to eq 3
        end

        it "should not count first specialties" do
          action = [ WOD20ActionSkill.new(specialties: [ "A" ]),
                     WOD20ActionSkill.new(specialties: [ "C" ] ) ]
          allow(@char).to receive(:wod20_action_skills) { action }
          expect(AbilityPointCounter.points_on_specialties(@char)).to eq 0
        end
      end

    end
  end
end
