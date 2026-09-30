import Foundation

/// Role: Field. Simulator demo crate. Device never writes this. Key: tnd.demo.v1. Punches one Tondo so Lodge is live.
enum FieldSeed {
    private static func fixed(_ value: String) -> UUID {
        UUID(uuidString: value) ?? UUID()
    }

    static func field(
        now: Date = Date(),
        calendar: Calendar = .current,
        caster: any RoundelCasting = LeadingDonorCast(),
        shelf: [CatalogRow] = GettyShelf.bundled.rows
    ) -> Field {
        let today = DayStamp.stamp(now, calendar: calendar)
        let rows = shelf
        func work(_ row: CatalogRow, id: UUID, role: WorkRole, dayOffset: Int) -> Work {
            var item = Work.loose(
                from: row,
                id: id,
                daykey: DayStamp.shifting(today, by: dayOffset, calendar: calendar)
            )
            item.role = role
            return item
        }

        let irises = work(rows[0], id: fixed("AAAAAAAA-0001-4000-8000-000000000001"), role: .loose, dayOffset: 0)
        let pontormo = work(rows[1], id: fixed("AAAAAAAA-0001-4000-8000-000000000002"), role: .loose, dayOffset: -1)
        let rembrandt = work(rows[2], id: fixed("AAAAAAAA-0001-4000-8000-000000000003"), role: .loose, dayOffset: -2)
        let ensor = work(rows[3], id: fixed("AAAAAAAA-0001-4000-8000-000000000004"), role: .loose, dayOffset: -3)
        let cezanne = work(rows[4], id: fixed("AAAAAAAA-0001-4000-8000-000000000005"), role: .loose, dayOffset: -4)
        let dyck = work(rows[5], id: fixed("AAAAAAAA-0001-4000-8000-000000000006"), role: .loose, dayOffset: -5)
        let monet = work(rows[6], id: fixed("AAAAAAAA-0001-4000-8000-000000000007"), role: .lodged, dayOffset: -6)
        let seurat = work(rows[7], id: fixed("AAAAAAAA-0001-4000-8000-000000000008"), role: .lodged, dayOffset: -7)

        let works = [irises, pontormo, rembrandt, ensor, cezanne, dyck, monet, seurat]
        let monetCard = RoundelHang.card(
            donor: monet,
            saved: [monet, irises, pontormo, rembrandt],
            caster: caster,
            groundIDs: [
                fixed("EEEEEEEE-0001-4000-8000-000000000011"),
                fixed("EEEEEEEE-0001-4000-8000-000000000012"),
                fixed("EEEEEEEE-0001-4000-8000-000000000013"),
                fixed("EEEEEEEE-0001-4000-8000-000000000014"),
            ]
        )
        let seuratCard = RoundelHang.card(
            donor: seurat,
            saved: [seurat, ensor, cezanne, dyck],
            caster: caster,
            groundIDs: [
                fixed("EEEEEEEE-0001-4000-8000-000000000021"),
                fixed("EEEEEEEE-0001-4000-8000-000000000022"),
                fixed("EEEEEEEE-0001-4000-8000-000000000023"),
                fixed("EEEEEEEE-0001-4000-8000-000000000024"),
            ]
        )
        let lodgeMarks = [
            LodgeMark(
                id: fixed("BBBBBBBB-0001-4000-8000-000000000001"),
                workID: monet.id,
                card: monetCard,
                daykey: monet.daykey
            ),
            LodgeMark(
                id: fixed("BBBBBBBB-0001-4000-8000-000000000002"),
                workID: seurat.id,
                card: seuratCard,
                daykey: seurat.daykey
            ),
        ]
        let chipMarks = [
            ChipMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000001"),
                workID: monet.id,
                groundID: monetCard.grounds.first { !$0.isDonor }?.id ?? fixed("FFFFFFFF-0001-4000-8000-000000000001"),
                daykey: monet.daykey
            ),
            ChipMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000002"),
                workID: seurat.id,
                groundID: seuratCard.grounds.first { !$0.isDonor }?.id ?? fixed("FFFFFFFF-0001-4000-8000-000000000002"),
                daykey: seurat.daykey
            ),
            ChipMark(
                id: fixed("DDDDDDDD-0001-4000-8000-000000000003"),
                workID: monet.id,
                groundID: monetCard.grounds.last { !$0.isDonor }?.id ?? fixed("FFFFFFFF-0001-4000-8000-000000000003"),
                daykey: monet.daykey
            ),
        ]
        var field = Field(
            schemaVersion: Field.currentSchema,
            onboardingComplete: true,
            works: works,
            tondo: .idle,
            lodgeMarks: lodgeMarks,
            chipMarks: chipMarks,
            peelLog: [
                PeelRef(kind: .lodge, markID: lodgeMarks[0].id),
                PeelRef(kind: .chip, markID: chipMarks[0].id),
                PeelRef(kind: .lodge, markID: lodgeMarks[1].id),
                PeelRef(kind: .chip, markID: chipMarks[1].id),
                PeelRef(kind: .chip, markID: chipMarks[2].id),
            ],
            cachedRows: Array(rows.prefix(6)),
            focusedWorkID: irises.id
        )
        try? field.cutTondo(
            now: now,
            calendar: calendar,
            caster: caster,
            groundIDs: [
                fixed("EEEEEEEE-0001-4000-8000-000000000001"),
                fixed("EEEEEEEE-0001-4000-8000-000000000002"),
                fixed("EEEEEEEE-0001-4000-8000-000000000003"),
                fixed("EEEEEEEE-0001-4000-8000-000000000004"),
            ]
        )
        return field
    }
}
